#!/usr/bin/env python3

import click
from project import Project


@click.command()
@click.option('--fam', help='Path to .fam file.')
@click.option('--sample', help='Path to .sample file.')
def link_sample(fam, sample):
    """Adds softlinks to genetic sample data.
    """
    p = Project()
    p.link_genetics(fam=fam, sample=sample, initialized=True)


if __name__ == '__main__':
    link_sample()
