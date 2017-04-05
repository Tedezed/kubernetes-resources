# Stolon Full Set

Sources: 
https://github.com/sorintlab/stolon
https://github.com/gravitational/stolon-app

## Install

You need install etcd:

`kubectl create -f ../etcd-cluster/etcd-simple.yaml`

Install Stolon:

`kubectl create -f stolon-full-set.yaml`

Default: `stolon password1`

## Init Cluster

https://github.com/sorintlab/stolon/blob/master/doc/initialization.md
https://github.com/sorintlab/stolon/blob/master/doc/cluster_spec.md

echo '{"initMode":"new"}' > /config ; exec gosu stolon stolon-sentinel --initial-cluster-spec /config