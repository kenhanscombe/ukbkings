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

        ln -S fam genotyped/ukb{ukbid}.fam
        ln -S sample imputed/ukb{ukbid}.sample
        ln -S {imputed}ukb_sqc_v2.txt imputed/ukb_sqc.txt
        ln -S {imputed}ukb_sqc_v2_fields.txt imputed/ukb_sqc_fields.txt


        ln -S {genotyped}ukb_binary_v2.bed genotyped/ukb{ukbid}.bed
        ln -S {genotyped}ukb_binary_v2.bed genotyped/ukb{ukbid}.bim

        for i in X XY 1 .. 22
        do
        ln -S {imputed}ukb_imp_chr"$i"_v3.bgen imputed/ukb_imp_chr"$i".bgen
        ln -S {imputed}ukb_imp_chr"$i"_v3.bgen.bgi imputed/ukb_imp_chr"$i".bgen.bgi
        ln -S {imputed}ukb_mfi_chr"$i"_v3.txt imputed/ukb_mfi_chr"$i".txt
        done
        """)


if __name__ == '__main__':
    import os
    import re
    import argparse

    parser = argparse.ArgumentParser()
    parser.add_argument('project')
    parser.add_argument('fam')
    parser.add_argument('sample')

    args = parser.parse_args()

    create_links(args.project, args.fam, args.sample)
