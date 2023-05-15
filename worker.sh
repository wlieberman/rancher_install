#!/bin/bash

sudo mkdir -p /etc/rancher/rke2/
cp ~rocky/agent-config.yaml /etc/rancher/rke2/config.yaml

# Install needed for Longhorn
yum -y --setopt=tsflags=noscripts install iscsi-initiator-utils
echo "InitiatorName=$(/sbin/iscsi-iname)" > /etc/iscsi/initiatorname.iscsi
systemctl enable iscsid
systemctl start iscsid

# Install a linux worker node
#curl -sfL https://get.rke2.io | sudo INSTALL_RKE2_TYPE="agent" sh -
curl -sfL https://get.rke2.io --output install.sh
chmod +x install.sh
INSTALL_RKE2_CHANNEL=v1.24 ./install.sh
# INSTALL_RKE2_CHANNEL=v1.24 INSTALL_RKE2_TYPE="agent" ./install.sh

# Enable the service
# sudo systemctl enable rke2-agent.service
sudo systemctl enable rke2-server.service

# Configure the rke2-agent service
# sudo mkdir -p /etc/rancher/rke2/

# Modify the /etc/rancher/rke2/config.yaml file
# Add below
# server: https://<server>:9345
# token: <token from the server node>

# Don't forget this
export PATH=$PATH:/var/lib/rancher/rke2/bin:/usr/local/bin/:$PATH
export KUBECONFIG=/etc/rancher/rke2/rke2.yaml
export CRI_CONFIG_FILE=/var/lib/rancher/rke3/agent/etc/crictl.yaml




# Start the service
#sudo systemctl start rke2-agent.service
sudo systemctl start rke2-server.service
# journalctl -u rke2-agent -f

# Each node has to have a unique node-name You can also set the "node-name" parameter in config.yaml file
