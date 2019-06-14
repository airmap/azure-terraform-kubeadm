#!/bin/bash
set -eux

HOME=/root

echo "Starting Kubernetes bootstrap process..."

### Setup SSH to control plane node 1 and 2
cat > /etc/ssh/ssh_config << EOL
Host ${control_plane_ip1}
   StrictHostKeyChecking=no
   UserKnownHostsFile=/dev/null
Host ${control_plane_ip2}
   StrictHostKeyChecking=no
   UserKnownHostsFile=/dev/null
EOL

systemctl restart ssh.service

eval $(ssh-agent)
ssh-add $HOME/.ssh/master.pem


### Misc system fixes
echo fs.inotify.max_user_watches=32768 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p
sudo echo "127.0.0.1 ${control_plane_endpoint}"  >> /etc/hosts

### Docker 
### https://kubernetes.io/docs/setup/cri/#docker
echo "Installing docker..."
/etc/kubernetes/docker_setup.sh

### Clear out the lost and found directory as a pre-flight requirement for kubeadm
rm -rf /var/lib/etcd/lost+found

### This should take only 30 seconds, but can take up to 5 minutes
echo "Initializing cluster..."
kubeadm init --config=/etc/kubeadm-config.yaml

#Configure kubeconfig
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install Kube-router CNI
echo "Setting up CNI..."
/etc/kubernetes/cni_setup.sh

### Copy certs to Control plane node 1 and 2
echo "Copying certs to other control plane nodes..."
if /etc/kubernetes/copy_certs.sh; then

   ### Setup Control Plane Node 1
   ssh -t "${username}"@${control_plane_ip1} "touch /home/${username}/kubernetes.lock"

   ###  Wait before initiating the last node, to ensure they are in order
   echo "sleeping for 30 seconds before intiating the last node"
   sleep 30

   ### Setup Control Plane Node 2
   ssh -t "${username}"@${control_plane_ip2} "touch /home/${username}/kubernetes.lock"
else
   echo "Could not copy certificates over to the rest of the control plane nodes."
fi