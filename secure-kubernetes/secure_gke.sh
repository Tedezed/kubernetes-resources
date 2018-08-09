#!/bin/bash

source variables

if [ "$1" = "current" ]; then
	chmod +x -R secure.d/*
	run-parts --regex="^[a-zA-Z0-9._-]+$" --report secure.d
	echo "Credentials:
	User: $(gcloud container clusters describe ${CLUSTER_NAME} --zone ${ZONE} --project ${PROJECT_ID} --format='value(masterAuth.username)')
	Pass: $(gcloud container clusters describe ${CLUSTER_NAME} --zone ${ZONE} --project ${PROJECT_ID} --format='value(masterAuth.password)')"
elif [ "$1" = "new" ]; then
	gcloud container clusters create "${CLUSTER_NAME}" \
		--service-account="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" \
		--no-enable-legacy-authorization \
		--enable-network-policy \
		--enable-autoscaling \
		--num-nodes=1 \
		--min-nodes=1 \
		--max-nodes=${MAX_NODES} \
		--machine-type=${MACHINE_TYPE} \
		--username=${GKE_USERNAME} \
		--enable-cloud-monitoring \
		--maintenance-window 2:00
	gcloud container clusters update "${CLUSTER_NAME}" \
		--project="${PROJECT_ID}" \
		--zone="${ZONE}" \
		--update-addons=KubernetesDashboard=DISABLED
	gcloud beta container clusters update "${CLUSTER_NAME}" \
		--project="${PROJECT_ID}" \
		--zone="${ZONE}" \
		--update-addons=NetworkPolicy=ENABLED
	echo "Credentials:
	User: $(gcloud container clusters describe ${CLUSTER_NAME} --zone ${ZONE} --project ${PROJECT_ID} --format='value(masterAuth.username)')
	Pass: $(gcloud container clusters describe ${CLUSTER_NAME} --zone ${ZONE} --project ${PROJECT_ID} --format='value(masterAuth.password)')"
else
	echo "Secure GKE
	- ./secure_gke.sh current 		# Secure current cluster in variables
	- ./secure_gke.sh new 			# Create a new secure cluster from variables

	More info:
	https://cloudplatform.googleblog.com/2017/11/precious-cargo-securing-containers-with-Kubernetes-Engine-18.html"
fi
