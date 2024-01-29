FROM hashicorp/terraform:latest

# Install AWS CLI
RUN apk --update add python3 && \
    pip3 install --upgrade pip && \
    pip3 install awscli

# Set the working directory to /workspace
WORKDIR /workspace
