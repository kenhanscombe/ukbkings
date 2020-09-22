#!/usr/bin/env python3

import os
import re
import click

from pathlib import Path


def build_project():
    """Sets up the UKB project directory for use with ukbkings.
    """
    os.system('''
        rm -rf src; mkdir src
        rm -rf resources; mkdir resources
        rm -rf log; mkdir log

        wget -O Snakefile https://raw.githubusercontent.com/kenhanscombe/ukbkings/master/Snakefile

        wget -P src/ -O src/munge_ukb.py https://raw.githubusercontent.com/kenhanscombe/ukbkings/master/src/munge_ukb.py
        wget -P src/ -O src/cluster.json https://raw.githubusercontent.com/kenhanscombe/ukbkings/master/src/cluster.json
        wget -O snake.py https://raw.githubusercontent.com/kenhanscombe/ukbkings/master/snake.py
        wget -O link.py https://raw.githubusercontent.com/kenhanscombe/ukbkings/master/link.py

        wget -P resources/ -O resources/Codings_Showcase.csv http://biobank.ctsu.ox.ac.uk/~bbdatan/Codings_Showcase.csv
        wget -P resources/ -nd -O resources/encoding.ukb biobank.ctsu.ox.ac.uk/crystal/util/encoding.ukb
        wget -P resources/ -nd -O resources/ukbunpack biobank.ndph.ox.ac.uk/showcase/util/ukbunpack
        wget -P resources/ -nd -O resources/ukbconv biobank.ndph.ox.ac.uk/showcase/util/ukbconv
        wget -P resources/ -nd -O resources/ukbgene biobank.ctsu.ox.ac.uk/crystal/util/ukbgene

        chmod +x snake.py
        chmod +x link.py
        chmod +x src/munge_ukb.py
        chmod +x resources/ukb*''')


def link_genetics(fam=None, sample=None, rel=None, initialized=False):
    """
    Creates symbolic links to genotyped and imputed genetic data.

    Args:
        fam (str): path to fam file
        sample (str): path to sample file
        rel (str): path to relatedness file
    """
    p = Path('.')
    wd_basename = p.absolute().name
    project_id = re.sub('ukb|_.*$', '', wd_basename)
    genotyped = '/scratch/datasets/ukbiobank/June2017/Genotypes/'
    imputed = '/scratch/datasets/ukbiobank/June2017/Imputed/'

    if not initialized:
        os.system(f'''
            rm -rf genotyped; mkdir genotyped
            rm -rf imputed; mkdir imputed

            ln -s {imputed}ukb_sqc_v2.txt imputed/ukb_sqc_v2.txt
            ln -s {imputed}ukb_sqc_v2_fields.txt imputed/ukb_sqc_v2_fields.txt

            ln -s {genotyped}ukb_binary_v2.bed genotyped/ukb_binary_v2.bed
            ln -s {genotyped}ukb_binary_v2.bim genotyped/ukb_binary_v2.bim

            for i in X XY $(seq 1 22)
            do
            ln -s {imputed}ukb_imp_chr"$i"_v3.bgen imputed/ukb_imp_chr"$i".bgen
            ln -s {imputed}ukb_imp_chr"$i"_v3.bgen.bgi imputed/ukb_imp_chr"$i".bgen.bgi
            ln -s {imputed}ukb_mfi_chr"$i"_v3.txt imputed/ukb_mfi_chr"$i".txt
            done
            ''')

    if fam:
        os.system(f'ln -s {fam} genotyped/ukb{project_id}.fam')

    if sample:
        os.system(f'ln -s {sample} imputed/ukb{project_id}.sample')

    if rel:
        os.system(f'ln -s {rel} imputed/ukb{project_id}.rel')


if __name__ == "__main__":
    build_project()
    link_genetics()
