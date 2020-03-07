FROM rocker/rstudio:3.6.2

# as of 2020-03-02, rocker/rstudio:latest seems to point to 3.6.1 which pulls in globals 0.12.4, too old for future, 

RUN apt-get update && \
    apt-get install -y curl && \
    curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl && \
    chmod +x ./kubectl && \
    cp kubectl /usr/local/bin

RUN Rscript -e "install.packages('remotes'); remotes::install_github('paciorek/future', ref = 'develop'); install.packages(c('future.apply','doFuture'))"

COPY setup-kube.R setup-kube.R

RUN cat setup-kube.R >> /usr/local/lib/R/etc/Rprofile.site
