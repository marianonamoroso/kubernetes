#!/bin/bash
# TOOL: kube-response.sh
# NEEDED BINS: kubectl
# NAMESPACE: ns
# AUTHOR: MA

#VARIABLES
option=0
exit=0
tput setaf 1; echo "AR - Kubernetes - ./kube-response.sh";tput sgr0;

while [ $exit == 0 ]; do

    # [MENU]  
    
    echo ""
    echo "[0 - Exit]"
    echo "[1 - Pods load]"
    echo "[2 - Nodes load]"
    echo "[3 - Deployments load]"
    echo "[4 - Logging running pods]"
    echo ""
    read -p "Please, select the number: " option

    case $option in
            0) # Exit
                echo ""
                tput setaf 1; echo "Thanks for using kube-response.sh";tput sgr0;
                echo ""
                let exit=1
                ;;
            
            1) # [1 - PODS LOAD]
                echo ""
                tput setaf 2; echo "[Pods]";tput sgr0;
                kubectl top pods -n ns
                echo ""
                tput setaf 2; echo "[Pods & Nodes]";tput sgr0;
                kubectl get pods -o wide -n ns
                ;;
            
            2) # [2 - NODES LOAD]
                echo ""
                tput setaf 2; echo "[Nodes]";tput sgr0;
                kubectl top nodes -n ns
                echo ""
                ;;
            
            3) # [3 - DEPLOYMENTS]
                echo ""
                tput setaf 2; echo "[Deployments]";tput sgr0;
                kubectl get deployments -n ns
                echo ""
                tput setaf 2; echo "[Horizontal Pod Autoscaling]";tput sgr0;
                kubectl get hpa -n ns

                ;;
            
            4)  # [4 - LOGGING RUNNING PODS]
                echo ""
                tput setaf 2; echo "[Logging running pods]";tput sgr0;
                echo ""
                for pod in $(kubectl get pods -n ns --no-headers=true | awk '{print $1}')
                do
                    tput sgr0 ; echo "Extracting logs of: $pod" 
                    echo "################################################">>$pod.logs
                    echo "POD_NAME:$pod">>$pod.logs
                    echo "################################################">>$pod.logs
                    date >$pod.logs
                    echo "" >>$pod.logs
                    kubectl logs $pod -n ns >>$pod.logs
                    tput setaf 2 ;echo "A log file was created: $pod.logs"
                    tput sgr0;echo ""
                done
                ls -la *.logs
                ;;

            *) echo ""; tput setaf 1; echo "Invalid option (you selected: $option)";tput sgr0; ;;
    esac

done

