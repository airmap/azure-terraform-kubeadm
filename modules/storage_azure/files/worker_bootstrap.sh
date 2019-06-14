#!/bin/bash
set -eux

HOME=/root

until nc -v -w1 ${control_plane_endpoint} 6443
do
        echo "Cluster is not ready. Sleeping..."
        sleep 10
done

echo "Starting Kubernetes Worker Node bootstrap process..."

### Misc system fixes
echo fs.inotify.max_user_watches=32768 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p

### Docker 
### https://kubernetes.io/docs/setup/cri/#docker
echo "Installing docker..."
/etc/kubernetes/docker_setup.sh

# Join the cluster
echo "Joining cluster..."
kubeadm join --config=/etc/kubernetes/join_conf.yaml

# Kuberouter Requirement
echo "Setting up kuberouter kernel requirement..."
sysctl net.bridge.bridge-nf-call-iptables=1

echo "Completed Kubernetes control plane bootstrap process!!!"