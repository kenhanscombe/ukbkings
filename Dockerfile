FROM rocker/r-ver:4.1.2

RUN sed -i '/en_GB.UTF-8/s/^# //g' /etc/locale.gen && \
    /usr/sbin/locale-gen
ENV LANG en_GB.UTF-8  
ENV LANGUAGE en_GB:en  
ENV LC_ALL en_GB.UTF-8 

RUN install2.r devtools dplyr stringr readxl lubridate
RUN R -e "devtools::install_github(\"kenhanscombe/ukbkings\", dependencies = TRUE, force = TRUE)"
RUN apt-get update && apt-get install -y \
    python3-pip
RUN pip3 install -U radian

CMD ["radian"]