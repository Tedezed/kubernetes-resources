#!/bin/bash 

MODE=$1
LIST_DOMAINS=$2
DNS_SERVER="8.8.8.8"
SLEEP_TIME="30"

function for_domain {
	MODE=$1
	LIST_DOMAINS=$2
	clear
	for d in $LIST_DOMAINS
	do
		if [ "$MODE" == "dig" ]
		then
			dig @$DNS_SERVER $d | grep "^$d"
		else
			echo "Firefox: $d - Status: $(curl -I $d 2>&1 | grep ^HTTP | cut -d ' ' -f 2)"
			firefox $d
		fi
	done
	sleep $SLEEP_TIME
}

if [ "$MODE" == "list_dns" ]
then
	while true
	do
		for_domain "dig" "$LIST_DOMAINS"
	done
elif [ "$MODE" == "kube_dns" ]
then
	while true
	do
		for_domain "dig" "$(kubectl get ingress --all-namespaces |  grep -v HOSTS | awk '{ print $3 }' | sed 's#,# #g' | tr '\n' ' ')"
	done
elif [ "$MODE" == "kube_firefox" ]
then
	for_domain "firefox" "$(kubectl get ingress --all-namespaces |  grep -v HOSTS | awk '{ print $3 }' | sed 's#,# #g' | tr '\n' ' ')"
else
	# LIST_DOMAIN="example1.com example2.com example3.com"
	echo "Example: bash check_list_domain.bash MODE [LIST_DOMAIN]
	Modes: list_dns, kube_dns, kube_firefox"
fi