FROM rocker/rstudio:latest AS builder

COPY pkg.txt .

# Install packages
# https://cran.rstudio.com/
RUN for p in $(cat pkg.txt); do R -e "install.packages('${p}', repos='http://cran.csie.ntu.edu.tw/')" ; done

COPY spark-3.4.1-bin-hadoop3 /opt/spark
ENV SPARK_HOME=/opt/spark
ENV PATH=${PATH}:${SPARK_HOME}/bin:${SPARK_HOME}/sbin
ENV PYSPARK_PYTHON=/usr/bin/python3

RUN apt update && apt install default-jdk scala -y

CMD [ "/init" ]
