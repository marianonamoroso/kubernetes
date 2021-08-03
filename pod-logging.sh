#!/bin/bash
# POD LOGGING
# AUTHOR: MARIANO AMOROSO
# BIN: kubectl
# NAMESPACE: emed

for pod in $(kubectl get pods -n emed --no-headers=true | awk '$serviceapi {print $1}')
do
	tput sgr0 ; echo "Extracting logs of: $pod" 
	date >$pod.logs
	echo "################################################">>$pod.logs
	echo "POD_NAME:$pod">>$pod.logs
       	echo "################################################">>$pod.logs
	kubectl logs $pod -n emed >>$pod.logs
	tput setaf 2 ;echo "A log file was created: $pod.logs"
	echo ""
done
