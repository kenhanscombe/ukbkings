#!/usr/bin/env python3

import click
from project import Project


@click.command()
@click.option('--ukbid', help='UKB project id, e.g., 12345.')
@click.option('--fam', help='Path to .fam file.')
@click.option('--sample', help='Path to .sample file.')
def link_sample(ukbid, fam, sample):
    """Adds softlinks to genetic sample data.
    """
    p = Project()
    p.link_genetics(ukbid=ukbid, fam=fam, sample=sample,
                    initialized=True)


if __name__ == '__main__':
    link_sample()
