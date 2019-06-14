#!/bin/bash
set -eux

IFS=$' '
CONTROL_PLANE_NODES="${control_plane_ip1} ${control_plane_ip2}"

for host in $CONTROL_PLANE_NODES; do
    scp /etc/kubernetes/pki/ca.crt "${username}"@$host:
    scp /etc/kubernetes/pki/ca.key "${username}"@$host:
    scp /etc/kubernetes/pki/sa.key "${username}"@$host:
    scp /etc/kubernetes/pki/sa.pub "${username}"@$host:
    scp /etc/kubernetes/pki/front-proxy-ca.crt "${username}"@$host:
    scp /etc/kubernetes/pki/front-proxy-ca.key "${username}"@$host:
    scp /etc/kubernetes/pki/etcd/ca.crt "${username}"@$host:etcd-ca.crt
    scp /etc/kubernetes/pki/etcd/ca.key "${username}"@$host:etcd-ca.key
    scp /etc/kubernetes/admin.conf "${username}"@$host:
done

