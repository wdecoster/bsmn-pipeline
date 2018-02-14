#!/bin/bash
#$ -cwd
#$ -pe threaded 36 

set -eu -o pipefail

if [[ $# -lt 2 ]]; then
    echo "Usage: $(basename $0) [sample name] [PU info]"
    exit 1
fi

source $(pwd)/run_info

SM=$1
PU=$2

printf -- "[$(date)] Start align_sort.\n---\n"

mkdir -p $SM/bam
$BWA mem -M -t 32 \
    -R "@RG\tID:$SM.$PU\tSM:$SM\tPL:illumina\tLB:$SM\tPU:$PU" \
    $REF $SM/fastq/$SM.$PU.R{1,2}.fastq.gz \
    |$SAMBAMBA view -S -f bam -l 0 /dev/stdin \
    |$SAMBAMBA sort -m 24GB -t 3 -o $SM/bam/$SM.$PU.sorted.bam --tmpdir=tmp /dev/stdin 
rm $SM/fastq/$SM.$PU.R{1,2}.fastq.gz

printf -- "---\n[$(date)] Finish align_sort.\n"
