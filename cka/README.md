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
        
2. <b>Join Worker Nodes</b>
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

<h2>Security</h2>

<h3>Certificates</h3>
        
1. <b>Create Client Key</b>.
       <details><summary>Show</summary>

        ```
        k create ns pyf
        ```
        </details>

2. <b>Create CertificateSigningRequest (CSR)</b>.
       <details><summary>Show</summary>

        ```
        k create ns pyf
        ```
        </details> 

3. <b>Approve CertificateSigningRequest (CSR)</b>.
       <details><summary>Show</summary>

        ```
        k create ns pyf
        ```
        </details>           
        
<h3>Roles</h3>

<h3>Service Account</h3>        
