#!/bin/bash
#$ -cwd
#$ -pe threaded 1

if [[ $# -lt 3 ]]; then
    echo "Usage: $(basename $0) [sample name] [file name] [location]"
    exit 1
fi

source $(pwd)/run_info

set -eu -o pipefail

SM=$1
FNAME=$2
LOC=$3

printf -- "---\n[$(date)] Start download: $FNAME\n"

mkdir -p $SM/downloads
if [[ $LOC =~ ^syn[0-9]+ ]]; then
    $SYNAPSE get $LOC --downloadLocation $SM/downloads/
elif [[ $LOC =~ ^s3:.+ ]]; then
    eval "$($PIPE_HOME/utils/nda_aws_token.sh -r ~/.nda_credential)"
    $AWS s3 cp $LOC $SM/downloads/
fi

printf -- "[$(date)] Finish downlaod: $FNAME\n---\n"
