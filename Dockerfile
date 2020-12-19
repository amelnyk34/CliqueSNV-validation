#FROM ubuntu:20.10

# Set up environment
FROM ubuntu:latest
RUN apt-get update && apt-get install make && apt-get -y update
RUN apt-get install -y build-essential python3.6 python3-pip python3-dev

RUN pip3 -q install pip --upgrade

FROM python:3.7
RUN pip3 install pandas biopython jupyter
#RUN pip3 install pandas biopython

# Download Clique SNV and validation files
RUN git clone https://github.com/vtsyvina/CliqueSNV.git && mkdir clique_snv_validation && mv -t clique_snv_validation CliqueSNV && \
    git clone https://github.com/Sergey-Knyazev/CliqueSNV-validation.git && \
    mv -t clique_snv_validation CliqueSNV-validation

# Download dependencies

# aBayesQR

RUN git clone https://github.com/SoYeonA/aBayesQR.git && mv -t clique_snv_validation aBayesQR
WORKDIR /clique_snv_validation/aBayesQR/
RUN make 
WORKDIR /

# PredictHaplo

RUN wget -P /clique_snv_validation/ "https://bmda.dmi.unibas.ch/software/PredictHaplo-Paired-0.6.tgz"
WORKDIR /clique_snv_validation/
RUN tar xfvz PredictHaplo-Paired-0.6.tgz && rm PredictHaplo-Paired-0.6.tgz
WORKDIR /clique_snv_validation/PredictHaplo/PredictHaplo-Paired-0.6
WORKDIR /

# Simseq

RUN git clone https://github.com/jstjohn/SimSeq.git && mv -t clique_snv_validation SimSeq

# Picard

RUN mkdir /clique_snv_validation/Picard/
RUN wget -P /clique_snv_validation/Picard/ "https://github.com/broadinstitute/picard/releases/download/2.23.9/picard.jar"

# Add Tini. Tini operates as a process subreaper for jupyter. This prevents kernel crashes.
ENV TINI_VERSION v0.6.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
RUN chmod +x /usr/bin/tini
ENTRYPOINT ["/usr/bin/tini", "--"]

CMD ["jupyter", "notebook", "--port=9000", "--no-browser", "--ip=0.0.0.0", "--allow-root","--NotebookApp.token='clique_snv'"]
