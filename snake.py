#!/usr/bin/env python3

import os
import click


@click.command()
@click.option('-n', 'dry_run', is_flag=True, default=False, help="Use option -n for a dry run.")
def snake(dry_run):
    """Rule runner for rules described in Snakefile.
    """
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

    if dry_run:
        os.system(snakemake_call + ' -n')
    else:
        os.system(snakemake_call)


if __name__ == '__main__':
    snake()
