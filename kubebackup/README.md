# Kubebackup

Backup all kubernetes in format json.

Execution, connect to your cluster and execute:

```
bash kubebackup_v1.bash
```

Your backup is in bkp.


## Other uses

Backup only one namespace:

```
bash kubebackup_v1.bash namespace_x
```

Backup small `svc,rc,cronjobs,secrets,ds,cm,deploy,hpa,sa,sts,ingress`

```
bash kubebackup_v1.bash namespace_x small
```

Backup custom:
```
bash kubebackup_v1.bash namespace_x custom svc,rc
```