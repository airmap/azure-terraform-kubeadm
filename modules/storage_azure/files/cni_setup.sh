#!/bin/bash
set -eux

HOME=/root

#https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/#pod-network

export KUBECONFIG=$HOME/.kube/config

sysctl net.bridge.bridge-nf-call-iptables=1

# Flannel

kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/a70459be0084506e4ec919aa1c114638878db11b/Documentation/kube-flannel.yml

