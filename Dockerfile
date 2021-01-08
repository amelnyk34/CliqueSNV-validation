#FROM ubuntu:20.10

# Set up environment
FROM ubuntu:latest
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install make && apt-get -y update
RUN apt-get install -y build-essential python3.6 python3-pip python3-dev

RUN pip3 -q install pip --upgrade

FROM python:3.7
RUN pip3 install pandas biopython jupyter
#RUN pip3 install pandas biopython

# Download Clique SNV and validation files
RUN git clone https://github.com/vtsyvina/CliqueSNV.git && mkdir clique_snv_validation && mv -t clique_snv_validation CliqueSNV && \
    git clone https://github.com/amelnyk34/CliqueSNV-validation.git && \
    mv -t clique_snv_validation CliqueSNV-validation

# Download dependencies

# aBayesQR

RUN git clone https://github.com/SoYeonA/aBayesQR.git && mv -t clique_snv_validation aBayesQR
WORKDIR /clique_snv_validation/aBayesQR/
RUN make 
RUN chmod 777 aBayesQR
WORKDIR /

# PredictHaplo

RUN mkdir /clique_snv_validation/PredictHaplo/ && wget -P /clique_snv_validation/PredictHaplo/ "https://bmda.dmi.unibas.ch/software/PredictHaplo-Paired-0.6.tgz"
WORKDIR /clique_snv_validation/PredictHaplo/
RUN tar xfvz PredictHaplo-Paired-0.6.tgz && rm PredictHaplo-Paired-0.6.tgz
#WORKDIR /clique_snv_validation/PredictHaplo/PredictHaplo-Paired-0.6
WORKDIR /

# Simseq

RUN git clone https://github.com/jstjohn/SimSeq.git && mv -t clique_snv_validation SimSeq

# Picard

RUN mkdir /clique_snv_validation/Picard/
RUN wget -P /clique_snv_validation/Picard/ "https://github.com/broadinstitute/picard/releases/download/2.23.9/picard.jar"

# Samtools

RUN wget https://github.com/samtools/samtools/releases/download/1.3.1/samtools-1.3.1.tar.bz2 -O samtools.tar.bz2 && \
    tar -xjvf samtools.tar.bz2 && \
    cd samtools-1.3.1 && \
    make && \
    make prefix=/usr/local/bin install && \
    ln -s /usr/local/bin/bin/samtools /usr/bin/samtools

#bwa

WORKDIR /
RUN git clone https://github.com/lh3/bwa.git && \
    cd bwa && \
    make

# Download reads

# HIV2exp_R1.fastq.gz
# HIV2exp_R2.fastq.gz
# HIV9exp_R1.fastq.gz
# HIV9exp_R2.fastq.gz

RUN wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=1AKaJssNBPjeokZN-lFOyxvEQjygHHSKh' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1AKaJssNBPjeokZN-lFOyxvEQjygHHSKh" -O /clique_snv_validation/CliqueSNV-validation/reads/HIV2exp_R1.fastq.gz && rm -rf /tmp/cookies.txt && \
    wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=1Ix1hceHgKVyCxnlUzKl7xWcMG3pGMHdD' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1Ix1hceHgKVyCxnlUzKl7xWcMG3pGMHdD" -O /clique_snv_validation/CliqueSNV-validation/reads/HIV2exp_R2.fastq.gz && rm -rf /tmp/cookies.txt && \
    wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=1FZi1RYgOnzTw3-W51gQQYnpvsKukJAgH' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1FZi1RYgOnzTw3-W51gQQYnpvsKukJAgH" -O /clique_snv_validation/CliqueSNV-validation/reads/HIV9exp_R1.fastq.gz && rm -rf /tmp/cookies.txt && \
    wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=1tmtU0eXuAzmMXcY11jD-N8h42UPnR7Kp' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1tmtU0eXuAzmMXcY11jD-N8h42UPnR7Kp" -O /clique_snv_validation/CliqueSNV-validation/reads/HIV9exp_R2.fastq.gz && rm -rf /tmp/cookies.txt

# Install Java and libblas
RUN apt-get update && \
    apt-get install -y openjdk-11-jre-headless libblas-dev

# Add Tini. Tini operates as a process subreaper for jupyter. This prevents kernel crashes.
ENV TINI_VERSION v0.6.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
RUN chmod +x /usr/bin/tini
ENTRYPOINT ["/usr/bin/tini", "--"]

CMD ["jupyter", "notebook", "--port=8888", "--no-browser", "--ip=0.0.0.0", "--allow-root","--NotebookApp.token='clique_snv'"]
#CMD ["jupyter", "notebook", "--no-browser", "--ip=0.0.0.0", "--allow-root","--NotebookApp.token='clique_snv'"]
