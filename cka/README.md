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

      ```
      ssh -i <your_key>.pem -o ServerAliveInterval=50 ubuntu@<ec2_public_ipv4_address> sudo swapoff -a # you have to execute the same command on each server/instance
      ```
      </details> 

2. <b>Join Worker Nodes</b>
      <details><summary>Show</summary>

      ```
      XXXXX
      ```
      </details>
