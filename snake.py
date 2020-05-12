#!/usr/bin/env python

import os
import argparse

if __name__ == "__main__":
  parser = argparse.ArgumentParser()
  parser.add_argument('dry', nargs='?', default='', help='"-n" for a dry-run.')
  args = parser.parse_args()
  
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
                --mem=10G" {}'.format(args.dry))
