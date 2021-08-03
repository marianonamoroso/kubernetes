#!/bin/bash
# TOOL: kube-response.sh
# NEEDED BINS: kubectl & aws-sso-magic
# NAMESPACE: emed
# AUTHOR: MA

#VARIABLES
option=0
exit=0
tput setaf 1; echo "AR - Kubernetes - ./kube-response.sh";tput sgr0;

while [ $exit == 0 ]; do

    # [MENU]  
    
    echo ""
    echo "[0 - Exit]"
    echo "[1 - EKS conn]"
    echo "[2 - Pods load]"
    echo "[3 - Nodes load]"
    echo "[4 - Deployments load]"
    echo "[5 - Logging running pods]"
    echo ""
    read -p "Please, select the number: " option

    case $option in
            0) # Exit
                echo ""
                tput setaf 1; echo "Thanks for using kube-response.sh";tput sgr0;
                echo ""
                let exit=1
                ;;
            
            1) # [1 - EKS CONNECTION]
                aws-sso-magic login --profile production-admin
                wait; tput setaf 2 ;echo "Login completed: aws-sso-magic login --profile production-admin";tput sgr0; echo ""
                aws-sso-magic login --eks --cluster emed-prod
                wait; tput setaf 2 ;echo "Cluster emed-prod configured:aws-sso-magic login --eks --cluster emed-prod";tput sgr0; echo ""
                export AWS_PROFILE=production-admin
                wait; tput setaf 2 ;echo "AWS_PROFILE configured:export AWS_PROFILE=production-admin";tput sgr0; echo ""
                ;;


            2) # [2 - PODS LOAD]
                echo ""
                tput setaf 2; echo "[Pods]";tput sgr0;
                kubectl top pods -n emed
                echo ""
                tput setaf 2; echo "[Pods & Nodes]";tput sgr0;
                kubectl get pods -o wide -n emed
                ;;
            
            3) # [3 - NODES LOAD]
                echo ""
                tput setaf 2; echo "[Nodes]";tput sgr0;
                kubectl top nodes -n emed
                echo ""
                ;;
            
            4) # [4 - DEPLOYMENTS]
                echo ""
                tput setaf 2; echo "[Deployments]";tput sgr0;
                kubectl get deployments -n emed
                echo ""
                tput setaf 2; echo "[Horizontal Pod Autoscaling]";tput sgr0;
                kubectl get hpa -n emed

                ;;
            
            5)  # [5 - LOGGING RUNNING PODS]
                echo ""
                tput setaf 2; echo "[Logging running pods]";tput sgr0;
                echo ""
                for pod in $(kubectl get pods -n emed --no-headers=true | awk '{print $1}')
                do
                    tput sgr0 ; echo "Extracting logs of: $pod" 
                    echo "################################################">>$pod.logs
                    echo "POD_NAME:$pod">>$pod.logs
                    echo "################################################">>$pod.logs
                    date >$pod.logs
                    echo "" >>$pod.logs
                    kubectl logs $pod -n emed >>$pod.logs
                    tput setaf 2 ;echo "A log file was created: $pod.logs"
                    tput sgr0;echo ""
                done
                ls -la *.logs
                ;;

            *) echo ""; tput setaf 1; echo "Invalid option (you selected: $option)";tput sgr0; ;;
    esac

done

