#!/usr/bin/env python

import os
import argparse

if __name__ == '__main__':
    parser = argparse.ArgumentParser()

    parser.add_argument('-n', '--dry-run',
                        action='store_true', help='Dry-run?')

    args = parser.parse_args()

    snakemake_call = 'snakemake \
                      --jobs 99 \
                      --cluster-config src/cluster.json \
                      --use-envmodules \
                      --cluster \
                          "sbatch \
                              --job-name={cluster.name} \
                              --partition={cluster.partition} \
                              --error={cluster.error} \
                              --out={cluster.out} \
                              --time {cluster.time} \
                              --mem=10G"'

    if args.dry_run:
        os.system(snakemake_call + ' -n')
    else:
        os.system(snakemake_call)
