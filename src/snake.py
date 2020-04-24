#!/usr/bin/env python

import os

if __name__ == "__main__":
  os.system('snakemake \
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
                --mem=10G" -n')
