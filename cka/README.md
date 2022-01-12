<img src="https://user-images.githubusercontent.com/8485060/147371404-edb634c8-d13c-4226-b632-b424bd999ad9.png" width=80 height=80/>
<h1>CKA</h1>
This repository contains helpful use commands, exercises for preparing the CKA.<br><br>  

I recommend you tackle the CKAD first in order to gain developer skills for managing deployments, multi-containers, services, network policies, ingress, configmaps, secrets, and storage. The stuff learned on your CKAD journey will let you be more comfortable to continue working with the CKA exam. You can check the following repo: https://github.com/marianonamoroso/kubernetes/tree/main/ckad<br>

Finally, I'll share with you my environment used for practicing CKA's required tasks. <b>FYI, I spent an extra cost in order to run AWS infrastructure needed (medium and large instance types)</b><br><br>

<b>Official Documentation:</b>

- Bootstrapping clusters with kubeadm: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/

<h2>AWS Infrastructure</h2>

<h3>EC2 Instances</h3>

- <b>Master Node</b>
  - OS: Ubuntu Server 20.04 LTS (HVM)
  - Type: t2.medium (2 vCPU and 4 Memory)
  - SSH Key
  - Name: master-node
- <b>Worker Nodes</b>
  - OS: Ubuntu Server 20.04 LTS (HVM)
  - Type: t2.large (4 vCPU and 8 Memory)
  - Quantity: 2
  - SSH Key
  - Name: worker-node

<h3>SSH Connection</h3>

```
chmod 400 <your_key>.pem
ssh -i <your_key>.pem -o ServerAliveInterval=50 ubuntu@<ec2_public_ipv4_address>
```
<h2>Administration</h2>

<h3>Installation</h3>

1. <b>Swap</b>
      <details><summary>Show</summary>

      ```
      ssh -i <your_key>.pem -o ServerAliveInterval=50 ubuntu@<ec2_public_ipv4_address> sudo swapoff -a # you have to execute the same command on each server/instance
      ```
      </details>
  
2. <b>Ports and Protocols</b>
      <details><summary>Show</summary>

      - <b>Control Plane - Security Group - Inbound</b>  
        - SSH	TCP -	22 - YOUR_PUBLIC_IPv4	  
        - Custom TCP - (2379 - 2380) - YOUR_VPC_CIDR_IPv4
        - Custom TCP - 6443 - 0.0.0.0/0	
        - Custom TCP - (10250 - 10252) - YOUR_VPC_CIDR_IPv4
        - Custom TCP - 6783 - YOUR_VPC_CIDR_IPv4
        
      - <b>Worker Node - Security Group - Inbound</b>   
        - Custom TCP - 10250 - YOUR_VPC_CIDR_IPv4
        - Custom TCP - (30000 - 32767) -	0.0.0.0/0
        - Custom TCP - 6783 - YOUR_VPC_CIDR_IPv4
      </details> 

3. <b>Hostnames</b>
      <details><summary>Show</summary>

      ```
      sudo vi /etc/hosts # you have to add the hosts on each instance
      ```
      ```  
      YOUR_MASTER_IPv4 master
      YOUR_WORKER-1_IPv4 worker1
      YOUR_WORKER-2_IPv4 worker2
      ```
      ```  
      ssh -i <your_key>.pem -o ServerAliveInterval=50 ubuntu@<master_public_ipv4_address> sudo hostnamectl set-hostname master # you have to change the name of the master node instance - login/logout
      ssh -i <your_key>.pem -o ServerAliveInterval=50 ubuntu@<worker-1_public_ipv4_address> sudo hostnamectl set-hostname worker1 # you have to change the name of the worker node instance - login/logout
      ssh -i <your_key>.pem -o ServerAliveInterval=50 ubuntu@<worker-2_public_ipv4_address> sudo hostnamectl set-hostname worker2 # you have to change the name of the worker node instance - login/logout 
      ```  
      </details>  
   
4. <b>Container Runtine</b>
      <details><summary>Show</summary>

      You have to go to the official documentation and follow the instructions: https://kubernetes.io/docs/setup/production-environment/container-runtimes/#containerd (you have to install containerd on each node)
      </details> 
        
5. <b>Installing kubeadm, kubelet and kubectl</b>
      <details><summary>Show</summary>

      You have to go to the official documentation and follow the instructions: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#installing-kubeadm-kubelet-and-kubectl (you have to install kubeadm, kubelet and kubectl on each node)
      </details>        

6. <b>Initializing</b>
      <details><summary>Show</summary>

      ```
      sudo kubeadm init
      ```
      ```  
      ls /etc/kubernetes
      systemctl status kubelet  
      ```
      </details>

7. <b>Kube Config</b>
      <details><summary>Show</summary>

      ```
      mkdir -p ~/.kube  
      sudo cp -i /etc/kubernetes/admin.conf ~/.kube/config
      sudo chown $(id -u):$(id -g) ~/.kube/config
      ```
      ```  
      alias k=kubectl
      k get node
      ```
      </details>
        
8. <b>Installing Wave Net</b>
      <details><summary>Show</summary>
        
      To configure the network plugin, you have to go to the official documentation and follow the instructions: https://www.weave.works/docs/net/latest/kubernetes/kube-addon/ 
      
      </details>
        
9. <b>Join Worker Nodes</b>
      <details><summary>Show</summary>

      ```
      kubeadm token create --print-join-command # you have to execute it on the master node
      ```
      ```  
      sudo kubeadm join <YOUR_IPv4> --token <YOUR_TOKEN> --discovery-token-ca-cert-hash <YOUR_SHA> # you have to execute it on the worker nodes
      ```
      ```   
      k get node # you have to execute it on the master node and you should see the new worker nodes 
      ```  
      </details>

<h3>Backup & Restore</h3>

2. <b>Installing etcdctl</b>
     <details><summary>Show</summary>

      ```
      sudo apt  install etcd-client # on your master node 
      etcdctl --help
      ```

      </details>
        
2. <b>Backing up ETCD</b>
     <details><summary>Show</summary>

      ```
      sudo cat /etc/kubernetes/manifests/etcd.yaml | grep -i /etc/kubernetes/pki
      sudo ETCDCTL_API=3 etcdctl snapshot save etcd-snapshot.db \ # backup file "etcd-snapshot.db
      --cacert "/etc/kubernetes/pki/etcd/ca.crt" \ # trusted-ca-file
      --cert="/etc/kubernetes/pki/etcd/server.crt" \ # cert-file
      --key="/etc/kubernetes/pki/etcd/server.key" # key-file
      ``` 
      ```
      ETCDCTL_API=3 etcdctl snapshot status etcd-snapshotdb
      ETCDCTL_API=3 etcdctl --write-out=table snapshot status etcd-snapshotdb
      ``` 

      </details>

3. <b>Restoring ETCD</b>
     <details><summary>Show</summary>
      
      ```
      sudo cat /etc/kubernetes/manifests/etcd.yaml # you can check the hostPath directory for ETCD 
      ``` 
      ```
      - hostPath:
          path: /var/lib/etcd # here
          type: DirectoryOrCreate
          name: etcd-data
      ```
      ```
      sudo ETCDCTL_API=3 etcdctl snapshot restore etcd-snapshotdb --data-dir /var/lib/etcd-backup # we create a new directory for the backup
      sudo ls /var/lib/etcd-backup/ 
      ``` 
      ```
      sudo vi /etc/kubernetes/manifests/etcd.yaml
      ```
      ```
      - hostPath:
          path: /var/lib/etcd-snapshotdb # new path
          type: DirectoryOrCreate
          name: etcd-data
      ```
      ``` 
      k get pod -A # you have to wait few minutes
      ```
      </details>

<h3>Upgrading Kubernetes Cluster</h3>

<h4>Master Node</h3>
        
1. <b>Upgrade kubeadm</b>        
      <details><summary>Show</summary>

      ```
      sudo -i
      apt update
      apt-cache madison kubeadm # checking all available versions
      kubeadm version  
      ```
      ```
      apt-mark unhold kubeadm && apt-get update && apt-get install -y kubeadm=1.23.1-00 && apt-mark hold kubeadm
      kubeadm version
      ```
      </details>  
        
2. <b>Upgrade Components</b>        
      <details><summary>Show</summary>

      ```
      kubeadm upgrade plan
      ```
      ```
      sudo kubeadm upgrade apply v1.23.1  
      ```  
      </details> 
        
3. <b>Drain Master</b>        
      <details><summary>Show</summary>

      ```
      k drain master --ignore-daemonsets # you have to execute it with the ubuntu user
      k get node # you should see the following status on the master node: SchedulingDisabled  
      ```
      </details> 
        
        
4. <b>Upgrade kubelet and kubectl</b>        
      <details><summary>Show</summary>

      ```
      sudo -i
      apt-mark unhold kubelet kubectl && apt-get update && apt-get install -y kubelet=1.23.1-00 kubectl=1.23.1-00 && apt-mark hold kubelet kubectl
      systemctl daemon-reload
      systemctl restart kubelet
      systemctl status kubelet
      ```
      </details>
        
5. <b>Uncordon Master</b>        
      <details><summary>Show</summary>

      ```
      k uncordon master # you have to execute it with the ubuntu user
      k get node
      ```
      </details> 
 
<h4>Worker Node</h3>
 
1. <b>Upgrade kubeadm</b>        
      <details><summary>Show</summary>

      ```
      sudo -i
      apt update
      apt-cache madison kubeadm # checking all available versions
      kubeadm version  
      ```
      ```
      apt-mark unhold kubeadm && apt-get update && apt-get install -y kubeadm=1.23.1-00 && apt-mark hold kubeadm
      kubeadm version
      ```
      </details>  
        
2. <b>Upgrade Components</b>        
      <details><summary>Show</summary>

      ```
      sudo kubeadm upgrade node
      ```

      </details> 
        
3. <b>Drain Worker</b>        
      <details><summary>Show</summary>

      ```
      k drain worker1 --ignore-daemonsets --force # you have to execute it with the ubuntu user on master node
      k get node
      ```
      </details> 
        
        
4. <b>Upgrade kubelet</b>        
      <details><summary>Show</summary>

      ```
      sudo -i
      apt update
      apt-cache madison kubeadm # checking all available versions
      kubeadm version  
      ```
      ```
      apt-mark unhold kubeadm && apt-get update && apt-get install -y kubeadm=1.23.1-00 && apt-mark hold kubeadm
      kubeadm version
      ```
      </details>
        
5. <b>Uncordon Worker</b>        
      <details><summary>Show</summary>

      ```
      k uncordon worker1
      k get node  
      ```
      </details> 
        
<h3>Contexts</h3>
        
1. <b>Configuration</b>        
      <details><summary>Show</summary>

      ```
      k config set-context --curent --namespace=<YOUR_NS>
      k config get-contexts # list your contexts configured on your kubeconfig file  
      k config current-context # list your current context  
      ```
      </details>        
        
<h3>Env Variables & Alias</h3>

- <b>Useful Stuff</b>        
    <details><summary>Show</summary>

    ```
    alias k='kubectl'
    export do='—dry-run=client -o yaml'
    ```
    </details>
        
<h2>Security</h2>

<h3>Certificates & Accounts</h3>
        
1. <b>Create Client Key</b>
      <details><summary>Show</summary>

      ```
      openssl genrsa -out devops-mamoroso.key 2048
      ls devops-mamoroso.key
      cat devops-mamoroso.key 
      ```
      ```
      openssl req -new -key devops-mamoroso.key -subj '/CN=mamoroso' -out devops-mamoroso.csr
      ls devops-mamoroso.csr
      cat devops-mamoroso.csr
      ``` 
      </details>

2. <b>Create CertificateSigningRequest (CSR)</b>
     <details><summary>Show</summary>

      You can check the official documentation in the following link: https://kubernetes.io/docs/reference/access-authn-authz/certificate-signing-requests/#create-certificatesigningrequest 

      ```
      cat devops-mamoroso.csr |base64 | tr -d "\n" # you have to copy the output
      vi devops-mamoroso-csr.yaml 
      ```
      ```
      apiVersion: certificates.k8s.io/v1
      kind: CertificateSigningRequest
      metadata:
        name: devops-mamoroso
      spec:
          request: <YOUR_CSR>
        signerName: kubernetes.io/kube-apiserver-client
        expirationSeconds: 86400  # one day
        usages:
        - client auth 
      ```
      ```
      k create -f devops-mamoroso-csr.yaml
      k get csr # devops-mamoroso is in peding state 
      ``` 
      </details> 

3. <b>Approve CertificateSigningRequest (CSR)</b>
     <details><summary>Show</summary>

      ```
      k certificate approve devops-mamoroso
      k get csr # now devops-mamoroso is appproved
      k get csr devops-mamoroso -o yaml # copy the certificate section
      echo <YOUR_CERTIFICATE> | base64 -d > devops-mamoroso.crt # you have to execute the following command in order to save your public key
      ```

      </details>           
       
4. <b>Generate ConfigFile (CF)</b>
     <details><summary>Show</summary>

      ```
      cp ~/.kube/config devops-mamoroso.conf # you will extract info of kubeconfig file
      vi devops-mamoroso.conf
      ```
      ```
      apiVersion: v1
      clusters:
      - cluster:
          certificate-authority-data: <YOUR_CERTIFICATE_AUTHORITY_DATA>
          server: <YOUR_SERVER_IP> # this information you can get it executing cluster-info
        name: kubernetes
      contexts:
      - context:
          cluster: kubernetes
          user: devops-mamoroso # change username
        name: devops-mamoroso@kubernetes # change username
      current-context: devops-mamoroso@kubernetes # change username
      kind: Config
      preferences: {}
      users:
      - name: devops-mamoroso # change username
        user:
          client-certificate: /home/ubuntu/devops-mamoroso.crt # you have to put your crt file (also you can paste your base64 crt info but you have to use client-certificate-data instead of client-certificate)
          client-key: /home/ubuntu/devops-mamoroso.key # you have to put your key file (also you can paste your base64 crt info but you have to use client-certificate-data instead of client-certificate)
      ```
      ``` 
      k --kubeconfig devops-mamoroso.conf get pod
      ```
      <b>Errors</b>
      - <i>Error from server (Forbidden): pods is forbidden: User "devops-mamoroso" cannot list resource "pods" in API group "" in the namespace "default"</i>
        - The output is correct, we did not have a clusterrole and clusterrolebinding so you have to keep moving forward to the next step (roles).
      - <i>Error in configuration: context was not found for specified context: <output></i>
        - You have to check your kubeconfig file (contexts, name, users, and so on).  
      - <i>Error You must be logged in to the server (Unauthorized)</i>
        - You did not create the user (please, check if your user was created, if not, you have to check the csr).
       
      </details>   

<h3>Roles</h3>
        
1. <b>Cluster Role</b>
      <details><summary>Show</summary>

      ```
      kubectl create clusterrole developer-cr --verb=create,get,list,update,delete --resource=pods,deployments.apps --dry-run=client -o yaml > devops-cr.yaml  
      vi devops-cr.yaml
      ```
      ```
      apiVersion: rbac.authorization.k8s.io/v1
      kind: ClusterRole
      metadata:
        creationTimestamp: null
        name: developer-cr
      rules:
      - apiGroups:
        - ""
        resources:
        - pods
        verbs:
        - create
        - get
        - list
        - update
        - delete
      - apiGroups:
        - apps
        resources:
        - deployments
        verbs:
        - create
        - get
        - list
        - update
        - delete
      ``` 
      ```
      k create -f devops-cr.yaml
      k get clusterrole devops-cr
      
      ```  
      </details>

2. <b>Role Binding</b>
      <details><summary>Show</summary>

      ```
      k create clusterrolebinding devops-crb --clusterrole=devops-cr --user=mamoroso
      k get clusterrolebinding.rbac.authorization.k8s.io/devops-crb
      k describe clusterrolebinding.rbac.authorization.k8s.io/devops-crb
      k --kubeconfig devops-mamoroso.conf get pod
      ```  
      </details>

<h3>Service Account</h3>
       
1. <b>Create SA</b>
     <details><summary>Show</summary>

      ```
      k create serviceaccount gitlab
      k describe serviceaccount gitlab # you can check the token generated
      k get secrets <YOUR_SA>
      k describe secrets <YOUR_SA_TOKEN> 
      ```

      </details>         

2. <b>Config File SA</b>
     <details><summary>Show</summary>

      ``` 
      cp ~/.kube/config serviceaccount-gitlab.conf # you will extract info of kubeconfig file
      k describe secrets gitlab-token-hckg8   # you have to copy the token variable
      vi serviceaccount-gitlab.conf
      ```
      ``` 
      apiVersion: v1
      clusters:
      - cluster:
          certificate-authority-data: <YOUR_CERTIFICATE_AUTHORITY_DATA>
          server: <YOUR_SERVER_IP> # this information you can get it executing cluster-info
        name: kubernetes
      contexts:
      - context:
          cluster: kubernetes
          user: gitlab
        name: gitlab@kubernetes
      current-context: gitlab@kubernetes
      kind: Config
      preferences: {}
      users:
      - name: gitlab
        user:
          token: <YOUR_SA_TOKEN> # you have to copy the out of the following commando: k describe secrets <YOUR_SA> 
      ```
      ```
      k --kubeconfig serviceaccount-gitlab.conf get pod # Remember the errors outlined on the step 4 of the "Certificates0 & Accounts" section (Generate ConfigFile CF)
      ``` 
      </details>         
       
3. <b>Roles SA</b>
     <details><summary>Show</summary>

      ```
      k create clusterrole gitlab-cr --verb=get,create,delete --resource=pods
      k describe clusterrole gitlab-cr              
      k create clusterrolebinding gitlab-cb --serviceaccount=default:gitlab --clusterrole=gitlab-cr
      k describe clusterrolebinding gitlab-cb    
      ```
      ```
      k auth can-i get deployments --as system:serviceaccount:default:gitlab -n default # no
      k auth can-i get pods --as system:serviceaccount:default:gitlab -n default # yes
      ``` 
      </details>
       
       
<h2>Observability</h2>
           
<h3>JSONPath</h3>
       
- <b>XXXX</b>        
    <details><summary>Show</summary>

    ```
    XXXX
    ```
    </details>       

<h2>Troubleshooting</h2>
       
- <b>XXXX</b>        
    <details><summary>Show</summary>

    ```
    XXXX
    ```
    </details>          
