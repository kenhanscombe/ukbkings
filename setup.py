#!/usr/bin/env python
import os

os.system(
  """
  mkdir src
  mkdir resources
  mkdir log

  wget https://raw.githubusercontent.com/kenhanscombe/ukbkings/master/Snakefile

  wget -P src/ https://raw.githubusercontent.com/kenhanscombe/ukbkings/master/src/munge_ukb.py
  wget -P src/ https://raw.githubusercontent.com/kenhanscombe/ukbkings/master/src/cluster.json
  wget https://raw.githubusercontent.com/kenhanscombe/ukbkings/master/snake.py
  
  wget -P resources/ http://biobank.ctsu.ox.ac.uk/~bbdatan/Codings_Showcase.csv
  wget -P resources/ -nd biobank.ctsu.ox.ac.uk/crystal/util/encoding.ukb
  wget -P resources/ -nd  biobank.ndph.ox.ac.uk/showcase/util/ukbunpack
  wget -P resources/ -nd  biobank.ndph.ox.ac.uk/showcase/util/ukbconv
  
  chmod +x snake.py
  chmod +x src/munge_ukb.py
  chmod +x resources/ukb*
  """)
