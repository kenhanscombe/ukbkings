#!/usr/bin/env python3

import os
import re
import click


class Project:
    def __init__(self):
        """Sets up the UKB project directory for use with ukbkings.
        """
        os.system('''
            mkdir src
            mkdir resources
            mkdir log

            wget -O Snakefile https://raw.githubusercontent.com/kenhanscombe/ukbkings/link-genetics/Snakefile

            wget -P src/ -O src/munge_ukb.py https://raw.githubusercontent.com/kenhanscombe/ukbkings/link-genetics/src/munge_ukb.py
            wget -P src/ -O src/cluster.json https://raw.githubusercontent.com/kenhanscombe/ukbkings/link-genetics/src/cluster.json
            wget -O snake.py https://raw.githubusercontent.com/kenhanscombe/ukbkings/link-genetics/snake.py
            wget -O link.py https://raw.githubusercontent.com/kenhanscombe/ukbkings/link-genetics/link.py

            wget -P resources/ -O resources/Codings_Showcase.csv http://biobank.ctsu.ox.ac.uk/~bbdatan/Codings_Showcase.csv
            wget -P resources/ -nd -O resources/encoding.ukb biobank.ctsu.ox.ac.uk/crystal/util/encoding.ukb
            wget -P resources/ -nd -O resources/ukbunpack biobank.ndph.ox.ac.uk/showcase/util/ukbunpack
            wget -P resources/ -nd -O resources/ukbconv biobank.ndph.ox.ac.uk/showcase/util/ukbconv

            chmod +x snake.py
            chmod +x link.py
            chmod +x src/munge_ukb.py
            chmod +x resources/ukb*''')

    def link_genetics(self, ukbid, fam, sample, initialized=False):
        """
        Creates symbolic links to genotyped and imputed genetic data.

        Args:
            ukbid (str): ukb project id
            fam (str): path to fam file
            sample (str): path to sample file
        """
        # ukbid = re.sub('^.*biobank/ukb|_.*$', '', project)
        genotyped = '/scratch/datasets/ukbiobank/June2017/Genotypes/'
        imputed = '/scratch/datasets/ukbiobank/June2017/Imputed/'

        if not initialized:
            os.system(
                f'''
                mkdir genotyped
                mkdir imputed

                ln -s {imputed}ukb_sqc_v2.txt imputed/ukb_sqc.txt
                ln -s {imputed}ukb_sqc_v2_fields.txt imputed/ukb_sqc_fields.txt

                ln -s {genotyped}ukb_binary_v2.bed genotyped/ukb{ukbid}.bed
                ln -s {genotyped}ukb_binary_v2.bim genotyped/ukb{ukbid}.bim

                for i in X XY $(seq 1 22)
                do
                ln -s {imputed}ukb_imp_chr"$i"_v3.bgen imputed/ukb_imp_chr"$i".bgen
                ln -s {imputed}ukb_imp_chr"$i"_v3.bgen.bgi imputed/ukb_imp_chr"$i".bgen.bgi
                ln -s {imputed}ukb_mfi_chr"$i"_v3.txt imputed/ukb_mfi_chr"$i".txt
                done
                ''')

        if fam:
            os.system(f'ln -s {fam} genotyped/ukb{ukbid}.fam')

        if sample:
            os.system(f'ln -s {sample} imputed/ukb{ukbid}.sample')


if __name__ == "__main__":
    project = Project()
    project.link_genetics()
