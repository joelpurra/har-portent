#!/usr/bin/env bash
set -e

# USAGE:
# 	"$0" <prefix> <parallelism> <domainlists>

prefix="$1"
cleanPrefix="$(echo "${prefix}" | sed -e 's/[^a-z0-9]/-/g' -e 's/---*/-/g' -e 's/-$//g')"
domainPrefix="$(echo "${prefix}" | cut -d'/' -f 3)"
shift
parallelDomains="$1"
shift
logname="domains.log"
datestamp=$(date -u +%F)
curbasedir="$PWD"
curdir=$(basename "$curbasedir")
projectRoot="$(cd -- "${BASH_SOURCE%/*}"; cd -- "$(git rev-parse --git-dir)/../"; echo "$PWD")"

# TODO: use http://gitslave.sourceforge.net/ instead?
thesisBaseDir="$projectRoot/../"
thesisBaseDir=$(cd -- "$thesisBaseDir"; echo "$PWD")
heedlessBaseDir="$thesisBaseDir/har-heedless/src"
dulcifyBaseDir="$thesisBaseDir/har-dulcify/src"

getFileTimestamp() {
	echo $(date -u +%FT%TZ | tr -d ':')
}

timestamp() {
	echo "#" "$1" `date` "$infile" >> "$logname"
}

addDomainPrefix(){
	sed "s_^_${domainPrefix}_"
}

removePrefixAndGetDomain(){
	sed "s_^${prefix}__" | cut -d'/' -f 1 | cut -d':' -f 1
}

read -d '' getOriginUrlFromHar <<-'EOF' || true
select(
	.log
	and
	.log.entries
	and
	((.log.entries | length) > 0)
	and
	.log.entries[0]
	and
	.log.entries[0].request
	and
	.log.entries[0].request.url
)
| .log.entries[0].request.url
EOF


echo "$(getFileTimestamp) start ${prefix}"

if [[ "$datestamp" != "$curdir" ]]; then
	mkdir -p "$datestamp"
	cd "$datestamp"
fi

for infilearg in "$@"; do
	infile="$curbasedir/$infilearg"
	wc -l "$infile"
	name="$(basename -s .txt "$infile")-$cleanPrefix"
	mkdir "$name"
	cd "$name"
	cp "$infile" "./domains.txt"
	cp "./domains.txt" "./input.txt"
	mkdir "hars"

	# Download once, then retry failed downloads twice
	for (( downloadIteration=1; downloadIteration<=3; downloadIteration++ ))
	do
		# Increase parallelism as failures are more and more certain to be definite.
		# Multiplies by 1, 3, 5
		parallelDomainsThisIteration="$(( $parallelDomains * ((($downloadIteration - 1) * 2) + 1) ))"

		cd "hars"
		timestamp "start #$downloadIteration"
		size=$(wc -l "../input.txt" | awk '{ print $1 }')
		echo "Downloading $size domains, up to $parallelDomainsThisIteration at a time"
		pv --line-mode --size "$size" -cN "in #$downloadIteration" "../input.txt" | "$heedlessBaseDir/domain/parallel.sh" "$prefix" "$parallelDomainsThisIteration" --screenshot true | pv --line-mode --size "$size" -cN "out #$downloadIteration" >> "$logname"
		timestamp "stop #$downloadIteration"
		cd ".."

		filetimestamp=$(getFileTimestamp)
		mv "hars/$logname" "./$(basename -s .log "$logname").$filetimestamp.log"

		# TODO: fix adding/removing www. more generically?
		<"./input.txt" addDomainPrefix | xargs -n 1 -I '{}' "$dulcifyBaseDir/domains/latest/single.sh" "hars/{}" | "$dulcifyBaseDir/util/cat-path.sh" | "$dulcifyBaseDir/extract/errors/failed-page-loads.sh" | jq --raw-output "$getOriginUrlFromHar" | removePrefixAndGetDomain > "./failed.txt"
		cp "./failed.txt" "./input.txt"
		mv "./failed.txt" "./failed.$downloadIteration.txt"
	done

	"$dulcifyBaseDir/one-shot/all.sh" "hars/"
	cd ".."
done

echo "$(getFileTimestamp) done ${prefix}"