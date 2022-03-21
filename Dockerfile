FROM rocker/r-ver:4.1.2

# locale
RUN echo 'en_GB.UTF-8 UTF-8' >> /etc/locale.gen \
    && /usr/sbin/locale-gen

RUN install2.r devtools dplyr stringr
RUN R -e "devtools::install_github(\"kenhanscombe/ukbkings\", dependencies = TRUE, force = TRUE)"
RUN apt-get update && apt-get install -y \
    python3-pip
RUN pip3 install -U radian

CMD ["radian"]