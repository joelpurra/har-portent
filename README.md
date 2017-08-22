# [har-portent](https://github.com/joelpurra/har-portent/)

Using [har-heedless](https://github.com/joelpurra/har-heedless/) to download and [har-dulcify](https://github.com/joelpurra/har-dulcify/) to analyze web pages in aggregate.


- [Downloads the front web page of all domains](https://github.com/joelpurra/har-heedless/) in a dataset.
  - Input is a text file with one domain name per line.
  - Downloads `n` domains in parallel.
    - Tested with over 100 parallel requests on a single of moderate speed and memory. YMMV.
    - Machine load heavily depends on the complexity and response rate of the average domain in the dataset.
  - Shows progress as well as expected time to finish downloads.
  - Download domains with different prefixes as separate dataset variations.
    - Default prefixes:
      - `http://`
      - `https://`
      - `http://www.`
      - `https://www.`
  - Retries failed domains twice to reduce effect of any intermittent problems.
    - Increases domain timeouts for failed domains.
  - Saves screenshots of all webpages.
- [Runs an analysis](https://github.com/joelpurra/har-dulcify/) on each dataset variation.
  - Outputs JSON files for analysis.
  - Prepared for aggregate dataset analysis to output tables (TSV/CSV), which in turn are prepared for graph creation.

Directory structure

```bash
# $PWD/$(date -u +%F)/$(basename "$domainlist")-$prefix/hars
```

## Usage

```bash
# Create directory structure and download all domains in domains.txt with a single prefix/variation.
# ./src/domains/download-and-analyze-https-www-combos.sh <prefix> <parallelism> <domainlists>
./src/domains/download-and-analyze-https-www-combos.sh 'https://www.' 10 many-domains.txt more-domains.txt 100k-se-domains.txt

# Create directory structure and download all domains in domains.txt with all four variations.
# ./src/domains/download-and-analyze-https-www-combos.sh <parallelism> <domainlists>
./src/domains/download-and-analyze-https-www-combos.sh 10 many-domains.txt more-domains.txt 100k-se-domains.txt
```

Other usage:

```bash
# Re-run question step in each dataset.
~/path/to/har-dulcify/src/util/dataset-foreach.sh $(find . -mindepth 2 -maxdepth 2 -type d) -- echo "--- Entering {} ---" '&&' ~/path/to/har-dulcify/src/one-shot/questions.sh

# Re-run aggregate and question step in each dataset.
~/path/to/har-dulcify/src/util/dataset-foreach.sh $(find . -mindepth 2 -maxdepth 2 -type d) -- echo "--- Entering {} ---" '&&' ~/path/to/har-dulcify/src/one-shot/aggregate.sh '&&' ~/path/to/har-dulcify/src/one-shot/questions.sh

# Copy selected files from each dataset.
OUTPUT="$HOME/path/to/output/analysis/$(date -u +%F)" ~/path/to/har-dulcify/src/util/dataset-query.sh $(find . -mindepth 2 -maxdepth 2 -type d) -- echo "--- Entering {} ---" '&&' 'T="$OUTPUT/$(basename "{}")"' '&&' echo '$T' '&&' mkdir -p '$T/' '&&' cp aggregate.disconnect.categories.organizations.json aggregates.analysis.json '*.log' 'failed*' google-gtm-ga-dc.aggregate.json origin-redirects.aggregate.json ratio-buckets.aggregate.json prepared.disconnect.services.analysis.json '$T/'
```

### Example output

Downloading two domains, one of which doesn't have HTTPS.

```text
$ ~/path/to/har-portent/src/domains/download-and-analyze-https-www-combos.sh 10 only-two-domains.txt
2015-01-31T113812Z start http://
       2 /Users/joelpurra/analyze/the/web/only-two-domains.txt
    in #1:    2  0:00:00 [26.7k/s] [=================================================================>] 100%
   out #1:    2  0:00:12 [ 157m/s] [=================================================================>] 100%
Downloading https://services.disconnect.me/disconnect-plaintext.json
Downloading https://publicsuffix.org/list/effective_tld_names.dat
2015-01-31T113855Z done http://
2015-01-31T113855Z start http://www.
       2 /Users/joelpurra/analyze/the/web/only-two-domains.txt
    in #1:    2  0:00:00 [23.3k/s] [=================================================================>] 100%
   out #1:    2  0:00:12 [ 164m/s] [=================================================================>] 100%
Downloading https://services.disconnect.me/disconnect-plaintext.json
Downloading https://publicsuffix.org/list/effective_tld_names.dat
2015-01-31T113937Z done http://www.
2015-01-31T113937Z start https://
       2 /Users/joelpurra/analyze/the/web/only-two-domains.txt
    in #1:    2  0:00:00 [26.3k/s] [=================================================================>] 100%
   out #1:    2  0:00:12 [ 157m/s] [=================================================================>] 100%
Downloading 1 domains, up to 30 at a time
    in #2:    1  0:00:00 [21.1k/s] [=================================================================>] 100%
   out #2:    1  0:00:12 [ 163m/s] [=================================================================>] 100%
Downloading 1 domains, up to 50 at a time
    in #3:    1  0:00:00 [29.9k/s] [=================================================================>] 100%
   out #3:    1  0:00:12 [ 163m/s] [=================================================================>] 100%
Downloading https://services.disconnect.me/disconnect-plaintext.json
Downloading https://publicsuffix.org/list/effective_tld_names.dat
2015-01-31T114019Z done https://
2015-01-31T114019Z start https://www.
       2 /Users/joelpurra/analyze/the/web/only-two-domains.txt
    in #1:    2  0:00:00 [30.3k/s] [=================================================================>] 100%
   out #1:    2  0:00:12 [ 163m/s] [=================================================================>] 100%
Downloading 1 domains, up to 30 at a time
    in #2:    1  0:00:00 [32.3k/s] [=================================================================>] 100%
   out #2:    1  0:00:12 [ 163m/s] [=================================================================>] 100%
Downloading 1 domains, up to 50 at a time
    in #3:    1  0:00:00 [31.7k/s] [=================================================================>] 100%
   out #3:    1  0:00:12 [ 163m/s] [=================================================================>] 100%
Downloading https://services.disconnect.me/disconnect-plaintext.json
Downloading https://publicsuffix.org/list/effective_tld_names.dat
2015-01-31T114101Z done https://www.
```



# Original purpose

[![Photo of Joel Purra presenting his master's thesis, named Swedes Online: You Are More Tracked Than You Think](https://files.joelpurra.com/projects/masters-thesis/video/2015-02-19/joel-purra_masters-thesis_2015-02-19_defense_highres.jpg)](https://joelpurra.com/projects/masters-thesis/)

Built as a component in [Joel Purra's master's thesis](https://joelpurra.com/projects/masters-thesis/) research, where downloading lots of front pages in the .se top level domain zone was required to analyze their content and use of internal/external resources.


## Citations

If you use, like, reference, or base work on the thesis report [*Swedes Online: You Are More Tracked Than You Think*](https://joelpurra.com/projects/masters-thesis/#thesis), the IEEE LCN 2016 paper [*Third-party Tracking on the Web: A Swedish Perspective*](https://joelpurra.com/projects/masters-thesis/#ieee-lcn-2016), open [source code](https://joelpurra.com/projects/masters-thesis/#open-source), or [open data](https://joelpurra.com/projects/masters-thesis/#open-data), please add at least on of the following two citations with a link to the project website: https://joelpurra.com/projects/masters-thesis/

[Master's thesis](https://joelpurra.com/projects/masters-thesis/#thesis) citation:

> Joel Purra. 2015. Swedes Online: You Are More Tracked Than You Think. Master's thesis. Linköping University (LiU), Linköping, Sweden. https://joelpurra.com/projects/masters-thesis/


[IEEE LCN 2016 paper](https://joelpurra.com/projects/masters-thesis/#ieee-lcn-2016) citation:

> J. Purra, N. Carlsson, Third-party Tracking on the Web: A Swedish Perspective, Proc. IEEE Conference on Local Computer Networks (LCN), Dubai, UAE, Nov. 2016. https://joelpurra.com/projects/masters-thesis/



---

Copyright (c) 2014, 2015, 2016, 2017 [Joel Purra](https://joelpurra.com/). Released under [GNU General Public License version 3.0 (GPL-3.0)](https://www.gnu.org/licenses/gpl.html).
