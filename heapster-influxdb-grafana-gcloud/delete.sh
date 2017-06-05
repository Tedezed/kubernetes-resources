kubectl delete -f heapster.yaml
kubectl delete -f influxdb.yaml
kubectl delete -f grafana.yaml

gcloud compute disks delete vol-grafana vol-influxdb