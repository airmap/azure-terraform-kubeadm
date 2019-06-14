#!/bin/bash
set -eux

HOME=/root

while [ ! -f /home/$username/kubernetes.lock ]
do
        echo "Lockfile is not present. Sleeping..."
        sleep 10
done

echo "Starting Kubernetes control plane bootstrap process..."

### Misc system fixes
echo fs.inotify.max_user_watches=32768 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p

### Docker 
### https://kubernetes.io/docs/setup/cri/#docker
echo "Installing docker..."
/etc/kubernetes/docker_setup.sh

# Clear out the lost and found directory as a pre-flight requirement for kubeadm
rm -rf /var/lib/etcd/lost+found

### Move certs
echo "Moving certificates..."
/etc/kubernetes/move_certs.sh

# Join the cluster
echo "Joining cluster..."
kubeadm join ${control_plane_endpoint}:6443 --token ${token} --discovery-token-unsafe-skip-ca-verification --experimental-control-plane

#Configure kubeconfig
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Kuberouter requirement
echo "Setting up kuberouter kernel requirement..."
sysctl net.bridge.bridge-nf-call-iptables=1

echo "Completed Kubernetes control plane bootstrap process!!!"