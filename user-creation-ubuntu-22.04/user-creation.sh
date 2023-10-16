#!/bin/bash

NEWUSER="einstein"

set -e
apt update -y
apt dist-upgrade -y

useradd -m -s /bin/bash -G sudo $NEWUSER
echo "$NEWUSER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-"$NEWUSER"

mkdir /home/$NEWUSER/.ssh

echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIZjMLJ2K+toRtwahVxJEFKbN+Qu8XYI8/6X8y+qqJYh $NEWUSER@deployment" > /home/$NEWUSER/.ssh/authorized_keys

chown -R $NEWUSER:$NEWUSER /home/$NEWUSER/
chmod 700 /home/$NEWUSER/.ssh/
chmod 600 /home/$NEWUSER/.ssh/*

systemctl restart ssh
