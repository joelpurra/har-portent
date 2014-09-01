#!/usr/bin/env bash
set -e

# USAGE:
# 	"$0" <parallelism> <domainlists>

"${BASH_SOURCE%/*}/download-and-analyze.sh" "http://" "$@"
"${BASH_SOURCE%/*}/download-and-analyze.sh" "http://www." "$@"
"${BASH_SOURCE%/*}/download-and-analyze.sh" "https://" "$@"
"${BASH_SOURCE%/*}/download-and-analyze.sh" "https://www." "$@"
