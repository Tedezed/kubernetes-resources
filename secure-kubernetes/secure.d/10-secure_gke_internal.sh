#!/bin/bash
set -x

gcloud container clusters update "${CLUSTER_NAME}" \
    --update-addons=KubernetesDashboard=DISABLED

gcloud container clusters update "${CLUSTER_NAME}" \
  --no-enable-legacy-authorization

gcloud beta container clusters update "${CLUSTER_NAME}" \
  --project="${PROJECT_ID}" \
  --zone="${ZONE}" \
  --update-addons=NetworkPolicy=ENABLED

gcloud beta container clusters update "${CLUSTER_NAME}" \
  --project="${PROJECT_ID}" \
  --zone="${ZONE}" \
  --enable-network-policy