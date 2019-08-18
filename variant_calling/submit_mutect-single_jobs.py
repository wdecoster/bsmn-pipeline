#!/usr/bin/env python3

import argparse
import glob
import os
import sys

cmd_home = os.path.dirname(os.path.realpath(__file__))
pipe_home = os.path.normpath(cmd_home + "/..")
job_home = cmd_home + "/job_scripts"
sys.path.append(pipe_home)

from library.config import log_dir
from library.job_queue import GridEngineQueue
q = GridEngineQueue()

def main():
    args = parse_args()
    jid = submit_jobs(args.sample, args.hold_jid)
    save_hold_jid("{sample}/mutect-single/hold_jid".format(sample=args.sample), jid)
    
def parse_args():
    parser = argparse.ArgumentParser(description='Alignment job submitter')
    parser.add_argument('sample', metavar='sample name')
    parser.add_argument('--hold_jid', default=None)
    return parser.parse_args()

def opt(sample, jid=None):
    opt = "-j y -o {log_dir} -l h_vmem=4G".format(log_dir=log_dir(sample))
    if jid is not None:
        opt = "-hold_jid {jid} {opt}".format(jid=jid, opt=opt)
    return opt

def save_hold_jid(fname, jid):
    with open(fname, 'w') as f:
        print(jid, file=f)
  
def submit_jobs(sample, ploidy, jid):
    jid = q.submit(
        "-t 1-24 {opt}".format(opt=opt(sample, jid)),
        "{job_home}/mutect-single_1.call.sh {sample}".format(
            job_home=job_home, sample=sample))
    jid = q.submit(opt(sample, jid),
        "{job_home}/mutect-single_2.concat_vcf.sh {sample}".format(
            job_home=job_home, sample=sample))
    return jid

if __name__ == "__main__":
    main()
