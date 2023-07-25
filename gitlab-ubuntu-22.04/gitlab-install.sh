#!/bin/bash
EXTURL=$(curl -s http://169.254.169.254/latest/meta-data/public-hostname)

# [GENERAL] 
# System updates
sudo apt update -y
sudo apt dist-upgrade -y

# [GITLAB]
# Install and configure the necessary dependencies
sudo apt install -y curl openssh-server ca-certificates tzdata perl

# Add the GitLab package repository and install the package
curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | sudo bash


sudo EXTERNAL_URL="$EXTURL" apt-get install -y gitlab-ce 


