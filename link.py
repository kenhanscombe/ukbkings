#!/usr/bin/env python3

import os
import click

from project import Project


@click.command()
@click.option('-f', '--fam', help='Path to .fam file.')
@click.option('-s', '--sample', help='Path to .sample file.')
def link_sample(fam, sample):
    """Adds softlinks to genetic sample data.
    """
    link_genetics(fam=fam, sample=sample, initialized=True)
    os.system('rm -rf __pycache__')


if __name__ == '__main__':
    link_sample()
