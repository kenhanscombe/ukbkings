#!/usr/bin/env python
import os

os.system(
  """
  mkdir src
  mkdir resources
  mkdir log

  wget -O Snakefile https://raw.githubusercontent.com/kenhanscombe/ukbkings/master/Snakefile

  wget -P src/ -O src/munge_ukb.py https://raw.githubusercontent.com/kenhanscombe/ukbkings/master/src/munge_ukb.py
  wget -P src/ -O src/cluster.json https://raw.githubusercontent.com/kenhanscombe/ukbkings/master/src/cluster.json
  wget -O snake.py https://raw.githubusercontent.com/kenhanscombe/ukbkings/master/snake.py
  
  wget -P resources/ -O resources/Codings_Showcase.csv http://biobank.ctsu.ox.ac.uk/~bbdatan/Codings_Showcase.csv
  wget -P resources/ -nd -O resources/encoding.ukb biobank.ctsu.ox.ac.uk/crystal/util/encoding.ukb
  wget -P resources/ -nd -O resources/ukbunpack biobank.ndph.ox.ac.uk/showcase/util/ukbunpack
  wget -P resources/ -nd -O resources/ukbconv biobank.ndph.ox.ac.uk/showcase/util/ukbconv
  
  chmod +x snake.py
  chmod +x src/munge_ukb.py
  chmod +x resources/ukb*
  """)
