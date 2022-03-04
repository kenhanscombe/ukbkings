FROM rocker/r-ver:4.1.2

RUN install2.r devtools dplyr stringr
RUN R -e "devtools::install_github(\"kenhanscombe/ukbkings\", dependencies = TRUE, force = TRUE)"
RUN apt-get update && apt-get install -y \
    python3-pip
RUN pip3 install -U radian

CMD ["radian"]