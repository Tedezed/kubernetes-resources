#!/bin/bash -e

# Adapted from: https://github.com/colhom/coreos-docs/blob/cluster-dump-restore/kubernetes/cluster-dump-restore.md
# Inspired in: https://gist.github.com/adambom/193d923ca51e8ffab325fe8e25fa03aa

# Example execution: bash kubebackup.bash

ABSOLUTE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/bkp"
mkdir -p $ABSOLUTE_PATH

if [ -z "$1" ]; then
    kubectl get --export -o=json ns | \
    jq '.items[] |
        del(.status,
            .metadata.uid,
            .metadata.selfLink,
            .metadata.resourceVersion,
            .metadata.creationTimestamp,
            .metadata.generation
        )' > $ABSOLUTE_PATH/1-ns.json
else
    kubectl get --export -o=json ns $1 | \
    jq 'del(.status,
            .metadata.uid,
            .metadata.selfLink,
            .metadata.resourceVersion,
            .metadata.creationTimestamp,
            .metadata.generation
        )' > $ABSOLUTE_PATH/1-ns.json
fi

kubectl get --export -o=json pv --all-namespaces | \
    jq '.items[] |
        select(.type!="kubernetes.io/service-account-token") |
        del(
            .successfulJobsHistoryLimit,
            .status,
            .spec.clusterIP, # clusterIP is dynamically assigned
            .spec.claimRef.uid,
            .spec.claimRef.resourceVersion,
            .metadata.uid,
            .metadata.selfLink,
            .metadata.resourceVersion,
            .metadata.creationTimestamp,
            .metadata.generation,
            .metadata.uid,
            .spec.template.spec.terminationGracePeriodSeconds,
            .spec.template.spec.restartPolicy,
            .spec?.ports[]?.nodePort? # Delete nodePort from service since this is dynamic
        ) |
        # Set reclaim policy to retain so we can recover volumes
        if .kind == "PersistentVolume" then 
            .spec.persistentVolumeReclaimPolicy = "Retain" 
        else
            . 
        end' >> $ABSOLUTE_PATH/2-pv-cluster.json

if [ "$2" == "small" ]; then
    cluster_content='svc,rc,cronjobs,secrets,ds,cm,deploy,hpa,sa,sts,ingress'
    cp $ABSOLUTE_PATH/2-pv-cluster.json $ABSOLUTE_PATH/tmp-2-pv-cluster.json
    cat $ABSOLUTE_PATH/tmp-2-pv-cluster.json | jq 'select(.spec.claimRef.namespace=="'$1'")' > $ABSOLUTE_PATH/2-pv-cluster.json
    rm $ABSOLUTE_PATH/tmp-2-pv-cluster.json
elif [ "$2" == "custom" ]; then
    cluster_content="$3"
else
    cluster_content='svc,rc,cronjobs,secrets,ds,cm,deploy,hpa,quota,limits,storageclass,sa,sts,ingress'
fi

echo "" > $ABSOLUTE_PATH/3-pvc-dump.json
echo "" > $ABSOLUTE_PATH/4-cluster-dump.json
echo "" > $ABSOLUTE_PATH/5-ep-cluster-dump.json
for ns in $(jq -r '.metadata.name' < $ABSOLUTE_PATH/1-ns.json);do
    echo "Namespace: $ns"
    kubectl --namespace="${ns}" get --export -o=json pvc | \
    jq '.items[] |
        select(.type!="kubernetes.io/service-account-token") |
        del(
            .successfulJobsHistoryLimit,
            .status,
            .spec.clusterIP, # clusterIP is dynamically assigned
            .spec.claimRef.uid,
            .spec.claimRef.resourceVersion,
            .metadata.uid,
            .metadata.annotations,
            .spec.storageClassName,
            .metadata.selfLink,
            .metadata.resourceVersion,
            .metadata.creationTimestamp,
            .metadata.generation,
            .metadata.uid,
            .spec.template.spec.terminationGracePeriodSeconds,
            .spec.template.spec.restartPolicy,
            .spec?.ports[]?.nodePort? # Delete nodePort from service since this is dynamic
        ) |
        # Set reclaim policy to retain so we can recover volumes
        if .kind == "PersistentVolume" then 
            .spec.persistentVolumeReclaimPolicy = "Retain" 
        else
            . 
        end' >> $ABSOLUTE_PATH/3-pvc-dump.json
    kubectl --namespace="${ns}" get --export -o=json $cluster_content | \
    jq '.items[] |
        select(.type!="kubernetes.io/service-account-token") |
        del(
            .successfulJobsHistoryLimit,
            .status,
            .spec.clusterIP, # clusterIP is dynamically assigned
            .spec.claimRef.uid,
            .spec.claimRef.resourceVersion,
            .metadata.uid,
            .metadata.selfLink,
            .metadata.resourceVersion,
            .metadata.creationTimestamp,
            .metadata.generation,
            .metadata.uid,
            .spec.template.spec.terminationGracePeriodSeconds,
            .spec.template.spec.restartPolicy,
            .spec?.ports[]?.nodePort? # Delete nodePort from service since this is dynamic
        ) |
        # Set reclaim policy to retain so we can recover volumes
        if .kind == "PersistentVolume" then 
            .spec.persistentVolumeReclaimPolicy = "Retain" 
        else
            . 
        end' >> $ABSOLUTE_PATH/4-cluster-dump.json
    kubectl --namespace="${ns}" get --export -o=json ep | \
    jq '.items[] |
        select(.type!="kubernetes.io/service-account-token") |
        del(
            .successfulJobsHistoryLimit,
            .status,
            .spec.clusterIP, # clusterIP is dynamically assigned
            .spec.claimRef.uid,
            .spec.claimRef.resourceVersion,
            .metadata.uid,
            .metadata.selfLink,
            .metadata.resourceVersion,
            .metadata.creationTimestamp,
            .metadata.generation,
            .metadata.uid,
            .spec.template.spec.terminationGracePeriodSeconds,
            .spec.template.spec.restartPolicy,
            .spec?.ports[]?.nodePort? # Delete nodePort from service since this is dynamic
        ) |
        # Set reclaim policy to retain so we can recover volumes
        if .kind == "PersistentVolume" then 
            .spec.persistentVolumeReclaimPolicy = "Retain" 
        else
            . 
        end' >> $ABSOLUTE_PATH/5-ep-cluster-dump.json
done

#python create_endpoints.py $ABSOLUTE_PATH
#mv $ABSOLUTE_PATH/output-ep.json $ABSOLUTE_PATH/5-ep-cluster-dump.json
