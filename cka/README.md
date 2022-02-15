<img src="https://user-images.githubusercontent.com/8485060/147371404-edb634c8-d13c-4226-b632-b424bd999ad9.png" width=80 height=80/>
<h1>CKA</h1>
This repository contains helpful use commands, exercises for preparing the CKA.<br><br>  

I recommend you tackle the CKAD first in order to gain developer skills for managing deployments, multi-containers, services, network policies, ingress, configmaps, secrets, and storage. The stuff learned on your CKAD journey will let you be more comfortable to continue working with the CKA exam. You can check the following repo: https://github.com/marianonamoroso/kubernetes/tree/main/ckad<br>

Last but not least, I'll share with you my environment used for practicing CKA's required tasks. FYI, I spent an extra cost in order to run the AWS infrastructure needed (medium and large instance types). You can automate the deployment using the terraform template which I created for achieving the CKA: https://github.com/marianonamoroso/kubernetes/tree/main/cka/terraform <br><br>

<b>Official Documentation:</b>

- Bootstrapping clusters with kubeadm: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/

<b>Exercises:</b><br> 

- https://github.com/alijahnas/CKA-practice-exercises

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

You can deploy the infrastructure listed before executing the following terraform template: https://github.com/marianonamoroso/kubernetes/tree/main/cka/terraform

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
      sudo swapoff -a # you have to execute the command in both worker nodes.
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

1. <b>Installing etcdctl</b>
     <details><summary>Show</summary>

      ```
      sudo apt install etcd-client # on your master node 
      etcdctl --help
      ```

      </details>
        
2. <b>Backing up ETCD</b>
     <details><summary>Show</summary>

      ```
      k describe -n kube-system pod etcd-master # here you can copy all the information needed for saving your backup
      ```
      ```
      sudo ETCDCTL_API=3 etcdctl snapshot save etcd-snapshot.db \ # backup file "etcd-snapshot.db
      --cacert "/etc/kubernetes/pki/etcd/ca.crt" \ # trusted-ca-file
      --cert="/etc/kubernetes/pki/etcd/server.crt" \ # cert-file
      --key="/etc/kubernetes/pki/etcd/server.key" # key-file
      ``` 
      ```
      ETCDCTL_API=3 etcdctl snapshot status etcd-snapshot.db
      ETCDCTL_API=3 etcdctl --write-out=table snapshot status etcd-snapshot.db
      ``` 

      </details>

3. <b>Restoring ETCD</b>
     <details><summary>Show</summary>
      
      ```
      k describe -n kube-system pod etcd-master # here you can copy all the information needed for restoring your backup
      ```
      ```
      sudo ETCDCTL_API=3 etcdctl --data-dir /var/lib/etcd-backup snapshot restore etcd-snapshot.db \
       --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt \
       --key=/etc/kubernetes/pki/etcd/server.key --initial-cluster=master=<YOUR_URL>:<PORT> \
       --initial-advertise-peer-urls=<YOUR_URL>:<PORT> --name master
      ``` 
      ```
      sudo ls /var/lib/etcd-backup/  
      sudo vi /etc/kubernetes/manifests/etcd.yaml
      ```
      ```
      volumeMounts:
      - mountPath: /var/lib/etcd-backup
        name: etcd-data
      - mountPath: /etc/kubernetes/pki/etcd
        name: etcd-certs
      ```
      ``` 
      - hostPath:
          path: /var/lib/etcd-backup # new path
          type: DirectoryOrCreate
          name: etcd-data
      ```
      ``` 
      k get pod -A # you have to wait few minutes; if you have any problem execute: sudo systemctl restart kubelet;strace -eopenat kubectl version;k get nodes
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
        
- <b>Configuration</b>        
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
    export do='--dry-run=client -o yaml'
    ```
    </details>
        
<h2>Security</h2>

<h3>Accounts</h3>
        
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
       
<h3>Certificates</h3>
       
1. <b>Check Certificate Expiration</b>      
    <details><summary>Show</summary>

    ```
    ls /etc/kubernetes/pki # certificates generated by kubeadm
    sudo kubeadm certs check-expiration
    ```
    ssh master
    ls /etc/kubernetes/pki | grep -i apiserver 
    openssl x509 -text -in /etc/kubernetes/pki/apiserver.crt | grep -i Validity -A2 # checking the apiserver.crt validity
    ```
 
    </details>   
       
2. <b>Renew Certificates</b>      
    <details><summary>Show</summary>

    ```  
    sudo kubeadm certs renew apiserver
    sudo kubeadm certs check-expiration # you have to see a new expiration date on apiserver
    ``` 
    </details> 

3. <b>View Kubelet Certs</b>      
    <details><summary>Show</summary>

    ``` 
    #client 
    sudo openssl x509  -noout -text -in /var/lib/kubelet/pki/kubelet-client-current.pem |grep -i "Issuer" # kubelet client certificate
    sudo openssl x509  -noout -text -in /var/lib/kubelet/pki/kubelet-client-current.pem | grep -i -A1 "Extended Key Usage" # kubelet client certificate
    ```
    ```
    #server  
    sudo openssl x509  -noout -text -in /var/lib/kubelet/pki/kubelet.crt | grep Issuer # kubelet server certificate
    sudo openssl x509  -noout -text -in /var/lib/kubelet/pki/kubelet.crt | grep "Extended Key Usage" -A1 # kubelet server certificate
    ```
    </details> 
    

    
<h2>Services & Networking</h2>
           
<h3>Service Types</h3>
       
1. <b>Create a deployment with the latest nginx image and two replicas.</b>
    <details><summary>Show</summary>

    ```
    k create deployment deploy-net --image=nginx:latest --replicas=2
    k get deployment deploy-net
    ```
    </details>
       
2. <b>Expose it's port 80 through a service of type NodePort.</b>
     <details><summary>Show</summary>

    ```
    k expose deployment deploy-net --type=NodePort --port=80 --target-port=80
    k get service/deploy-net # you have to check the two endpoints associated with the deployment
    ```
    </details>
       
3. <b>Show all elements, including the endpoints.</b>
    <details><summary>Show</summary>

    ```
    k get ep deploy-net
    k describe ep deploy-net  
    ```
    </details>  
       
       
4. <b>Get the nginx index page through the NodePort.</b>      
    <details><summary>Show</summary>

    ```
    k get pod -l app=deploy-net -o wide # you have to check which node is the host
    k get node -o wide # you have to copy the internal ipv4
    wget -O- <INTERNAL_NODE_IP>:<NODE_PORT> 
    ```
    </details>       

<h3>Ingress</h3>
       
1. <b>Keep the previous deployment of nginx and add a new deployment using the image bitnami/apache with two replicas.</b>
    <details><summary>Show</summary>

    ```
    k create deployment bitnami --image=bitnami/apache:latest --replicas=2
    k get deployment
    k get pod
    ```
    </details>      

2. <b>Expose its port 8080 through a service and query it.</b>
    <details><summary>Show</summary>

    ```
    k expose deployment bitnami --port=8080 --target-port=8080 --type=NodePort
    k describe svc bitnami
    k get pod -o wide
    k get node -o wide
    curl <NODE_IP>:8080  
    ```
    </details>    
      
3. <b>Deploy nginx ingress controller</b>
    <details><summary>Show</summary>

    ```
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.46.0/deploy/static/provider/baremetal/deploy.yaml
    k get svc -n ingress-nginx  
    ```
    </details>    

4. <b>Create an ingress service that redirects /nginx to the nginx service and /apache to the apache service.</b>
    <details><summary>Show</summary>

    ```
    vi ingress.yaml
    ```
    ```
    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
      name: web-ingress
    spec:
      rules:
      - host: nginx-apache.com
        http:
          paths:
          - path: /nginx
            pathType: Prefix
            backend:
              service:
                name: deploy-net # nginx service name
                port:
                  number: 80 # nginx deployment port
          - path: /apache
            pathType: Prefix
            backend:
              service:
                name: bitnami # bitnami service name
                port:
                  number: 8080 # nginx deployment port
    ```
    ```
    k create -f ingress.yaml 
    k describe ingress web-ingress  
    ```  
    </details>  
         
<h2>Observability</h2>

<h3>Cluster Information</h3>
       
- <b>Master</b>        
    <details><summary>Show</summary>

    ```
    k get nodes # nodes
    sudo cat /etc/kubernetes/manifests/kube-apiserver.yaml # CIDR:service-cluster-ip-range=<IP>/<CIDR> (master)
    sudo find /etc/cni/net.d # networking or CNI (master)
    ps aux | grep -i kubelet # process
    ```
    k get pod -n kube-system # static-pods
    k get ds -n kube-system # deamonsets
    k get deploy -n kube-system # deployments
    ```
    </details>       


<h3>JSONPath & More</h3>
       
- <b>Nodes</b>        
    <details><summary>Show</summary>

    ```
    k get nodes -o jsonpath='{.items[*].metadata.name}{"\n"}' # listing nodenames
    k get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{"\n"}{end}' # listing nodenames with range  
    k get nodes -o jsonpath='{.items[1].metadata.labels}{"\n"}' # listing node[1] labels
    ```
    ```
    k get node -A --sort-by=.metadata.name
    k get node -A --sort-by=.metadata.uid
    ```
    </details>       

- <b>Pods</b>        
    <details><summary>Show</summary>

    ```
    k get pods -o jsonpath='{.items[*].metadata.name}{"\n"}' # listing podnames
    k get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{"\n"}{end}' # listing podnames with range  
    k get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.metadata.labels}{"\t"}{"\n"}{end}' # listing pod names and labels
    k get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[].image}{"\t"}{"\n"}{end}' # listing pod names and images
    k get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[*].resources}{"\n"}{end}' # listing pod resources  
    ```
    ```
    k get pod -A --sort-by=.metadata.creationTimestamp
    k get pod -A --sort-by=.metadata.name
    ```
    ```
    k get pod -o wide # you have to check on which node the pod was provisioned
    crictl ps | grep -i pod-crictl # ssh <WORKER_NODE>
    crictl inspect <ID> | grep runtimeType
    crictl logs <ID> # ssh <WORKER_NODE> 'crictl logs <ID>' &> pod-crictl.log
    ```  
    </details>   

- <b>Namespaces</b>        
    <details><summary>Show</summary>
    
    ```
    k api-resources --namespaced -o name # list all namespaced kubernetes resources
    ```
    </details>  

    
<h2>Troubleshooting</h2>
       
- <b>Kubelet Issues</b>        
    <details><summary>Show</summary>

    ```
    k get node # status: NotReady 
    ssh <node>   
    ```
    ```
    service kubelet status # location issues
    which kubelet
    sudo vi /etc/systemd/system/kubelet.service.d/10-kubeadm.conf # you have this location on the service status ouput executed before
    ```
    ```  
    ExecStart=/usr/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_CONFIG_ARGS $KUBELET_KUBEADM_ARGS $KUBELET_EXTRA_ARGS # on our case we have to change the ExecStart variable
    ```
    ```
    sudo systemctl deamon-reload  
    sudo systemctl restart kubelet
    sudo systemctl status kubelet  
    ```  
    </details>          

- <b>Certifcate Issues</b>        
    <details><summary>Show</summary>

    ```
    k get node # you are not able to connect to the cluster
    cat ~/.kube/config # you have to check cluster, server and certificates  
    ```   
    ```
    echo "certificate-authority-data" | base64 -d # <YOUR_CERT_AUTH_DATA>
    sudo cat /etc/kubernetes/pki/ca.crt # you have to check if it's the same  
    ```
      
    </details>   
          
- <b>Context Issues</b>        
    <details><summary>Show</summary>

    ```
    k config get-contexts # you can list all contexts
    k config current-context # also, you can execute the following command: cat ~/.kube/config | grep current
    k config view # you have to check server IP and PORT (6443) 
    ```   
    ```
    vi ~/.kube/config # you have to change the server IP or/and PORT if it's wrong
    ```
      
    </details>   
      
- <b>Logging</b>        
    <details><summary>Show</summary>

    ```
    k logs <POD_NAME> # you can execute log command in order to get logs from pods
    ```   
      
    </details>        
      
- <b>Monitoring Components</b>            
    <details><summary>Show</summary>
    
    Install the metrics server and show metrics for nodes and for pods in kube-system namespace.
    ```
    k top pod # You should see the following error: Metrics API not available  
    ```
    ```
    kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.5.2/components.yaml  
    k top pod -n kube-system # You have to wait for the server to get metrics
    ```
    If you have the following error "Readiness probe failed: HTTP probe failed with statuscode: 500" you have to add "- --kubelet-insecure-tls" on the container section. 
    ```  
    k edit deploy -n kube-system metrics-server  
    ```  
    ```  
    containers:
    - args:
      - --cert-dir=/tmp
      - --secure-port=8448
      - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
      - --kubelet-insecure-tls # you have to add the following line
    ```
    ```
    k get events -A --sort-by=.metadata.creationTimestamp
    ```
    ```
    k delete pod deploy-critical-69bbc84d78-p47rb # forcing pod deletion
    kubectl get events -n default --sort-by=.metadata.creationTimestamp | grep -i kill # you can check the logs 
    ```  
    </details>         

- <b>Monitoring Applications</b>            
    <details><summary>Show</summary>
    
    ```
    k run nginx-monitor --image=nginx --labels=env=monitor --port=80 --dry-run=client -o yaml> nginx-monitor.yaml
    vi nginx-monitor.yaml  
    ```      
    ```
    apiVersion: v1
    kind: Pod
    metadata:
      creationTimestamp: null
      labels:
        env: monitor
      name: nginx-monitor
    spec:
      containers:
      - image: nginx
        name: nginx-monitor
        ports:
        - containerPort: 80
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 15
          periodSeconds: 20
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5  
     ```
     ```
     k create -f nginx-monitor.yaml 
     k get pod/nginx-monitor
     k describe pod/nginx-monitor  
     ``` 
