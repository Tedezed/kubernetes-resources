#!/bin/bash
set -x

gcloud iam service-accounts create "${SA_NAME}" \
  --display-name="${SA_NAME}"

gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --member "serviceAccount:${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role roles/logging.logWriter

gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --member "serviceAccount:${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role roles/monitoring.metricWriter

gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --member "serviceAccount:${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role roles/monitoring.viewer

gcloud container node-pools delete \
	$(gcloud container node-pools list --cluster="${CLUSTER_NAME}" | tail -n +2 | awk '{ print $1 }') \
	--cluster="${CLUSTER_NAME}"

gcloud container node-pools create "${NODE_POOL}" \
  --service-account="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" \
  --enable-autoscaling \
  --num-nodes=1 \
  --min-nodes=1 \
  --max-nodes=${MAX_NODES} \
  --machine-type=${MACHINE_TYPE} \
  --maintenance-window 2:00 \
  --cluster="${CLUSTER_NAME}"
