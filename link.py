#!/usr/bin/env python3

import os
import click

from project import link_genetics


@click.command()
@click.option('-f', '--fam', default=None, help='Path to fam file.')
@click.option('-s', '--sample', default=None, help='Path to sample file.')
@click.option('-r', '--rel', default=None, help='Path to relatedness file.')
def link_sample(fam, sample, rel):
    """Adds softlinks to genetic sample data.
    """
    def print_help():
        ctx = click.get_current_context()
        click.echo(ctx.get_help())
        ctx.exit()

    if not (fam or sample or rel):
        print_help()

    link_genetics(fam=fam, sample=sample, rel=rel, initialized=True)
    os.system('rm -rf __pycache__')


if __name__ == '__main__':
    link_sample()
