#!/usr/bin/env python3


def create_links(project, fam, sample):
    """Creates symbolic links to genotyped and imputed genetic data.

    Args:
        project (str): ukb project directory
        fam (str): path to fam file
        sample (str): path to sample file
    """
    ukbid = re.sub('^.*biobank/ukb|_.*$', '', project)
    genotyped = '/scratch/datasets/ukbiobank/June2017/Genotypes/'
    imputed = '/scratch/datasets/ukbiobank/June2017/Imputed/'

    os.system(
        f"""
        mkdir genotyped
        mkdir imputed

        ln -s {fam} genotyped/ukb{ukbid}.fam
        ln -s {sample} imputed/ukb{ukbid}.sample
        ln -s {imputed}ukb_sqc_v2.txt imputed/ukb_sqc.txt
        ln -s {imputed}ukb_sqc_v2_fields.txt imputed/ukb_sqc_fields.txt


        ln -s {genotyped}ukb_binary_v2.bed genotyped/ukb{ukbid}.bed
        ln -s {genotyped}ukb_binary_v2.bed genotyped/ukb{ukbid}.bim

        for i in X XY $(seq 1 22)
        do
        ln -s {imputed}ukb_imp_chr"$i"_v3.bgen imputed/ukb_imp_chr"$i".bgen
        ln -s {imputed}ukb_imp_chr"$i"_v3.bgen.bgi imputed/ukb_imp_chr"$i".bgen.bgi
        ln -s {imputed}ukb_mfi_chr"$i"_v3.txt imputed/ukb_mfi_chr"$i".txt
        done
        """)


if __name__ == '__main__':
    import os
    import re
    import argparse

    parser = argparse.ArgumentParser()
    parser.add_argument('-p', '--project', help='ukb project directory')
    parser.add_argument('-f', '--fam', help='path to fam file')
    parser.add_argument('-s', '--sample', help='path to sample file')

    args = parser.parse_args()

    create_links(args.project, args.fam, args.sample)
