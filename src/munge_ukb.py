#!/usr/bin/env python

import argparse
import os
import sys
import numpy as np
import pandas as pd
import re

from bs4 import BeautifulSoup


class UKBMunger:

    variable_type = {'Sequence': 'int',
                     'Integer': 'int',
                     'Categorical (single)': 'str',
                     'Categorical (multiple)': 'str',
                     'Continuous': 'float',
                     'Text': 'str',
                     'Date': 'str',
                     'Time': 'str',
                     'Compound': 'str',
                     'Binary object': 'str',
                     'Curve': 'str'}

    description_edits = {' - ': '_',
                         '-': '_',
                         ' ': '_',
                         '__': '_',
                         ',|': '',
                         r'\.': '_',
                         'uses_data.coding.*simple_list.': '',
                         'uses_data.coding.*hierarchical_tree.': ''}

    def __init__(self, html=None, basket=None, out_dir='./'):
        self.html = html
        self.basket = basket
        self.out_dir = out_dir

    @staticmethod
    def table_to_df(tbl):
        """
        Converts an html table to a pandas dataframe
        """
        return pd.read_html(str(tbl), index_col=0, header=0)[0]

    def munge_html(self):
        """
        Reads a UKB project html file and makes a field-to-name lookup table.
        """
        if not os.path.exists(self.html):
            raise Exception('Bad path to html file.')

        with open(self.html, 'r', encoding='ISO-8859-1') as file:
            text = file.read()

        soup = BeautifulSoup(text, 'lxml')
        tables = soup.find_all('table')

        field_to_name = self.table_to_df(tables[1])
        field_to_name = field_to_name.fillna(method='ffill')

        cat_codes = (field_to_name['Description']
                     .str.findall('data-coding [0-9]*')
                     .apply(pd.Series))

        if cat_codes.empty:
            field_to_name['categorical_coding'] = ''
        else:
            field_to_name['categorical_coding'] = cat_codes

        field_to_name['categorical_coding'] = \
            field_to_name['categorical_coding'].str.replace('data-coding ', '')

        field_to_name['python_type'] = pd.Series(
            [self.variable_type.get(t) for t in field_to_name['Type']]
        )

        description = (field_to_name['Description']
                       .str
                       .lower() + '_f' + field_to_name['UDI'])

        for pattern, replacement in self.description_edits.items():
            field_to_name['name'] = [
                re.sub(pattern, replacement, x) for x in description.values]
            description = field_to_name['name']

        field_to_name = field_to_name.replace(
            {'encoded_anonymised_participant_id_feid': 'eid'})

        # UKB typos can lead to duplicate names
        duplicated = field_to_name['name'].duplicated()
        duplicated_index = field_to_name[duplicated].index

        field_to_name.loc[duplicated_index, 'name'] = 'duplicate_' + \
            field_to_name.loc[duplicated_index, 'name']

        (field_to_name
         .rename(columns={'UDI': 'field',
                          'Type': 'ukb_type'})[
             ['field', 'name', 'categorical_coding', 'ukb_type']]
         .to_csv(self.out_dir + self.basket + '_field_finder.txt', sep='\t',
                 index=False, na_rep='NA'))

        return print('Field-to-name table written to ',
                     self.out_dir + self.basket + '_field_finder.txt\n')


def create_parser():
    parser = argparse.ArgumentParser(description='UKB phenotype data munger.')
    parser.add_argument('--html', type=str, metavar='',
                        help='Path to UKB html')
    parser.add_argument('--basket', type=str, metavar='',
                        help='UKB basket number (e.g., ukb12345)')
    parser.add_argument('--out-dir', type=str, metavar='', default='./',
                        help='Path to output directory (default = ./)')
    return parser


def main():
    parser = create_parser()
    args = parser.parse_args()
    args = parser.parse_args()

    m = UKBMunger(args.html, args.basket, args.out_dir)
    m.munge_html()


if __name__ == '__main__':
    main()
