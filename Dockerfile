FROM rocker/r-ver:4.3.3

LABEL maintainer="Steve Vissault <steve.vissault@inrs.ca>"

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libgit2-dev \
    libglpk-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    curl \
    git \
    unzip \
    parallel \
    python3 \
    python3-pip \
    openjdk-11-jre-headless \
    build-essential \
    wget \
    less \
    bc \
    && rm -rf /var/lib/apt/lists/*

# Install FLASH (v1.2.11+)
RUN wget https://github.com/dstreett/FLASH2/archive/refs/tags/2.2.00.tar.gz && \
    tar -xzf 2.2.00.tar.gz && \
    cd FLASH2-2.2.00 && \
    make && \
    mv flash2 flash && \
    cp flash /usr/local/bin && \
    cd .. && rm -rf FLASH2-2.2.00 2.2.00.tar.gz

# Install VSEARCH v2.14.2+
RUN wget https://github.com/torognes/vsearch/releases/download/v2.30.0/vsearch-2.30.0-linux-x86_64.tar.gz && \
    tar -xzf vsearch-2.30.0-linux-x86_64.tar.gz && \
    cp vsearch-2.30.0-linux-x86_64/bin/vsearch /usr/local/bin && \
    rm -rf vsearch-2.30.0-linux-x86_64*

# Install R packages (no version pinning)
RUN install2.r --error \
    bslib \
    cli \
    config \
    desc \
    fontawesome \
    glue \
    golem \
    httpuv \
    pkgload \
    processx \
    reactable \
    shiny \
    shinyjs \
    shinyWidgets \
    stringr \
    usethis

# Install Python dependencies
RUN pip3 install --no-cache-dir biopython pandas numpy

# Set source code
COPY . /barqueShinyApp
WORKDIR /barqueShinyApp
RUN git submodule update --init --recursive

EXPOSE 3838

# Start Shiny Server
CMD ["Rscript", "app.R"]
