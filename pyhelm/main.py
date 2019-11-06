#!/usr/bin/python3
# By Tedezed
# Source: https://github.com/flaper87/pyhelm

from pyhelm.chartbuilder import ChartBuilder
from pyhelm.tiller import Tiller

import subprocess, time

tiller_host = '127.0.0.1'
mode_dry_run = False
mode_shell = True

subprocess.call('''kubectl port-forward $(kubectl get pod --all-namespaces | awk '{ print $2 }' | grep tiller) -n kube-system 44134:44134 &''', shell=mode_shell)
subprocess.call('''kubectl port-forward $(kubectl get pod --all-namespaces | awk '{ print $2 }' | grep tiller) -n kube-system 44135:44135 &''', shell=mode_shell)
time.sleep(3)

try:
	tiller = Tiller(tiller_host)
	chart = ChartBuilder({"name": "nginx-ingress", "source": {"type": "repo", "location": "https://kubernetes-charts.storage.googleapis.com"}})
	output_install = tiller.install_release(chart.get_helm_chart(), dry_run=mode_dry_run, name="test-tiller-python2", namespace="test-tiller-python")
	print(output_install)

	subprocess.call('''killall kubectl''', shell=mode_shell)
	print("[INFO] Success")

except Exception as e:
	subprocess.call('''killall kubectl''', shell=mode_shell)
	print("[ERROR] %s" % e)
