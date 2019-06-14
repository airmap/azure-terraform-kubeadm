#!/bin/bash
set -eux

mkdir -p /etc/kubernetes/pki/etcd
cp /home/${username}/ca.crt /etc/kubernetes/pki/
cp /home/${username}/ca.key /etc/kubernetes/pki/
cp /home/${username}/sa.pub /etc/kubernetes/pki/
cp /home/${username}/sa.key /etc/kubernetes/pki/
cp /home/${username}/front-proxy-ca.crt /etc/kubernetes/pki/
cp /home/${username}/front-proxy-ca.key /etc/kubernetes/pki/
cp /home/${username}/etcd-ca.crt /etc/kubernetes/pki/etcd/ca.crt
cp /home/${username}/etcd-ca.key /etc/kubernetes/pki/etcd/ca.key
cp /home/${username}/admin.conf /etc/kubernetes/admin.conf