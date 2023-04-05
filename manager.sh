#!/bin/bash

# Let's get some info so we can automate more
echo "What is the full path to your pem key: "
read KEY
echo "What is the internal IP for worker1: "
read WORKER1
echo "What is the internal IP for worker2: "
read WORKER2

# Install needed for Longhorn
yum -y --setopt=tsflags=noscripts install iscsi-initiator-utils
echo "InitiatorName=$(/sbin/iscsi-iname)" > /etc/iscsi/initiatorname.iscsi
systemctl enable iscsid
systemctl start iscsid

# This is the server installation on the manager(s)
# Run this as root
#    curl -sfL https://get.rke2.io | sudo sh -
curl -sfL https://get.rke2.io --output install.sh
chmod +x install.sh
INSTALL_RKE2_CHANNEL=v1.24 ./install.sh

# Enable the service
sudo systemctl enable rke2-server.service

# Start the service
sudo systemctl start rke2-server.service

# Follow the logs
# journalctl -u rke2-server -f

# Remember to add /var/lib/rancher/rke2/bin to your path
echo "Add /var/lib/rancher/rke2/bin to your path for additional tools"
echo "export PATH=$PATH:/var/lib/rancher/rke2/bin:/usr/local/bin/:$PATH"
echo "export KUBECONFIG=/etc/rancher/rke2/rke2.yaml"
echo "export CRI_CONFIG_FILE=/var/lib/rancher/rke3/agent/etc/crictl.yaml"

export PATH=$PATH:/var/lib/rancher/rke2/bin:/usr/local/bin/:$PATH
export KUBECONFIG=/etc/rancher/rke2/rke2.yaml
export CRI_CONFIG_FILE=/var/lib/rancher/rke3/agent/etc/crictl.yaml

echo "Two cleanup scripts will be installed to the path at /usr/local/bin/rke2. They are: rke2-killall.sh and rke2-uninstall.sh."
echo "A kubeconfig file will be written to /etc/rancher/rke2/rke2.yaml."
echo "A token that can be used to register other server or agent nodes will be created at /var/lib/rancher/rke2/server/node-token"


## Build the agent-config.yaml files
export SERVER="server: https://$HOSTNAME:9345"
export TOKEN="token: `cat /var/lib/rancher/rke2/server/token`"
echo $SERVER > agent-config.yaml
echo $TOKEN >> agent-config.yaml

# Copy the agent-config.yaml to the worker nodes
scp -i $KEY rocky@$WORKER1:
scp -i $KEY rocky@$WORKER2:

# Copy the agent-config.yaml file to each agent node in /etc/rancher/rke2/config.yaml