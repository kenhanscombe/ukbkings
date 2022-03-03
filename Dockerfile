FROM rocker/r-ver:4.1.2

RUN install2.r devtools
RUN R -e "devtools::install_github(\"kenhanscombe/ukbkings\", dependencies = TRUE)"

CMD ["R"]