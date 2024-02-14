FROM ubuntu:22.04

RUN apt update && \
    apt -y install sudo

# curl
RUN sudo apt install curl -y

# Install AWS CLI dependencies
RUN apt-get update && \
    apt-get install -y \
    python3 \
    python3-pip 

# Install AWS CLI using pip
RUN pip3 install --upgrade awscli 

# Clean up the package cache to reduce image size
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Update the package list and install necessary dependency
RUN apt-get update && \
    apt-get install -y wget unzip git make && \
    rm -rf /var/lib/apt/lists/*

# Download and install Terraform
RUN wget -q https://releases.hashicorp.com/terraform/1.3.9/terraform_1.3.9_linux_amd64.zip && \
    unzip terraform_1.3.9_linux_amd64.zip && \
    mv terraform /usr/local/bin/ && \
    rm terraform_1.3.9_linux_amd64.zip

WORKDIR /pipeline
COPY . /pipeline
