FROM rocker/rstudio:4.1.0

# as of 2020-03-02, rocker/rstudio:latest seems to point to 3.6.1 which pulls in globals 0.12.4, too old for future, 

# kubectl is only needed for monitoring/diagnostics. 
RUN apt-get update && \
    apt-get install -y curl \
           openssh-client \
           git && \
    curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl && \
    chmod +x ./kubectl && \
    cp kubectl /usr/local/bin

RUN Rscript -e "install.packages(c('future', 'future.apply','doFuture', 'data.table', 'prophet', 'forecast', 'remotes'))"
RUN R -e 'remotes::install_github("cloudyr/AzureStor")'

COPY setup-kube.R setup-kube.R

RUN cat setup-kube.R >> /usr/local/lib/R/etc/Rprofile.site

# Download public key for github.com
RUN mkdir -p -m 0700 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts

RUN mkdir -p /data/R/tmp
RUN chmod a+w /data/R -R
RUN cd /data/R

# Clone private repository
RUN --mount=type=ssh git clone git@github.com:circlekeurope/zoltar-sandbox.git /data/R/git
RUN cd /data/R/git && git checkout feature/tidyverse_downloads

RUN chmod a+w /data/R/git -R
RUN chmod a+w /data/R/tmp -R
RUN chmod +x /data/R/git/Azure/daily.sh
RUN cd /data/R/git && git rev-parse --short HEAD > /data/R/version
RUN cd /data/R
COPY storage.key /data/R/storage.key

WORKDIR /data/R/git/Azure

ENV OMP_NUM_THREADS=1
ENV OPENBLAS_NUM_THREADS=1
