FROM codercom/enterprise-base:ubuntu

# Switch to root for installations
USER root

# Install essential tools including curl for Coder agent download
RUN apt-get update && \
    apt-get install -y \
    curl \
    ca-certificates \
    git \
    build-essential \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Create docker group if it doesn't exist
RUN getent group docker || groupadd docker

# Create coder user if it doesn't exist, with sudo access
RUN id -u coder &>/dev/null || useradd -m -s /bin/bash coder && \
    echo "coder ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/coder

# Switch back to coder user
USER coder
WORKDIR /home/coder
