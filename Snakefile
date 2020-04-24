# Munge UK Biobank data

import os
import glob
import re
import pandas as pd

from pathlib import Path


project = Path("Snakefile").parent


dataset_ids = [re.sub(r'^.*ukb|\.enc', '', d) for d in glob.glob('raw/*.enc')]

ukbunpack = 'resources/ukbunpack'
ukbconv = 'resources/ukbconv'


rule all:
    input:
        expand('raw/ukb{id}.enc_ukb', id=dataset_ids),
        expand('phenotypes/ukb{id}.csv', id=dataset_ids),
        expand('phenotypes/ukb{id}.html', id=dataset_ids),
        expand('phenotypes/ukb{id}_field_finder.txt', id=dataset_ids),
        'phenotypes/ukb.field'


rule ukbunpack_decrypt:
    input:
        enc = 'raw/ukb{id}.enc',
        key = 'raw/ukb{id}.key'
    output:
        'raw/ukb{id}.enc_ukb'
    shell:
        """
        {ukbunpack} {input.enc} {input.key}
        """


rule ukbconv_convert:
    input:
        'raw/ukb{id}.enc_ukb'
    output:
        csv = 'phenotypes/ukb{id}.csv',
        html = 'phenotypes/ukb{id}.html'
    params:
        out = 'phenotypes/ukb{id}',
        enc = 'resources/encoding.ukb'
    shell:
        """
        {ukbconv} {input} csv -o{params.out} -e{params.enc}
        {ukbconv} {input} docs -o{params.out} -e{params.enc}
        """


rule munge_ukb_html:
    input:
        html = 'phenotypes/ukb{id}.html'
    output:
        finder = 'phenotypes/ukb{id}_field_finder.txt'
    params:
        basket = 'ukb{id}',
        out_dir = 'phenotypes/'
    # conda:
    #     "src/munge_ukb_env.yml"
    envmodules:
        "devtools/anaconda/2019.3-python3.7.3"
    shell:
        """
        src/munge_ukb.py \
            --html {input.html} \
            --basket {params.basket} \
            --out-dir {params.out_dir}
        """


rule concatenate_field_finders:
    input:
        expand('phenotypes/ukb{id}_field_finder.txt', id=dataset_ids)
    output:
        'phenotypes/ukb.field'
    run:
        with open('phenotypes/ukb.field', "wb") as wf:

            with open(
                    "phenotypes/ukb{}_field_finder.txt".format(dataset_ids[0]),
                    "rb") as rf:
                header = [next(rf) for lines in range(1)]
                wf.write(header[0])

            for id in dataset_ids:
                with open(
                        "phenotypes/ukb{}_field_finder.txt".format(id),
                        "rb") as rf:
                    next(rf)
                    wf.write(rf.read())
