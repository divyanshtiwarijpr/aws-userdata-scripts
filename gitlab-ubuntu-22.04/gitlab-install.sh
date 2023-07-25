#!/bin/bash
# [GENERAL] 
# System updates
sudo apt update -y
sudo apt dist-upgrade -y

# [GITLAB]
# Install and configure the necessary dependencies
sudo apt install -y curl openssh-server ca-certificates tzdata perl

# Add the GitLab package repository and install the package
curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.deb.sh | sudo bash


sudo EXTERNAL_URL="https://gitlab.divyansh.net" apt-get install -y gitlab-ce 


