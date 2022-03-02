Bootstrap: docker
From: continuumio/miniconda3

%post
    wget -O /packed_environment.tar.gz https://raw.githubusercontent.com/kenhanscombe/ukbkings/master/packed_environment.tar.gz
    tar xvzf /packed_environment.tar.gz -C /opt/conda
    conda-unpack
    rm /packed_environment.tar.gz