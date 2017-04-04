# Stolon Full Set

Sources: 
https://github.com/sorintlab/stolon
https://github.com/gravitational/stolon-app

## Install

You need install etcd:

`kubectl create -f ../etcd-cluster/etcd-set.yaml`

Install Stolon:

`kubectl create -f stolon-full-set.yaml`

Default: `stolon password1`