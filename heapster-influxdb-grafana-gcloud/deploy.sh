kubectl delete -f heapster.yaml
kubectl delete -f influxdb.yaml
kubectl delete -f grafana.yaml

gcloud compute disks create --size 20GB vol-grafana
gcloud compute disks create --size 20GB vol-influxdb

kubectl create -f heapster.yaml
kubectl create -f influxdb.yaml
kubectl create -f grafana.yaml

