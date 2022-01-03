<img src="https://user-images.githubusercontent.com/8485060/147371404-edb634c8-d13c-4226-b632-b424bd999ad9.png" width=80 height=80/>
<h1>CKA</h1>
This repository contains helpful use commands, exercises for preparing the CKA. I recommend you tackle the CKAD first in order to gain developer skills for managing deployments, multi-containers, services, network policies, ingress, configmaps, secrets, and storage. The stuff learned on your CKAD journey will let you be more comfortable to continue working with the CKA exam.<br><br>

<b>Official Documentation:</b>

- Bootstrapping clusters with kubeadm: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/

<h2>AWS Infrastructure</h2>

- <b>EC2 Instances</b>
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

<h2>SSH Instance Connection</h2>

```
chmod 400 <your_key>.pem
ssh -i <your_key>.pem -o ServerAliveInterval=50 ubuntu@<ec2_public_ipv4_address>
```
<h2>Variables & Useful Stuff</h2>

```
alias k='kubectl'
export do='—dry-run=client -o yaml'
kubectl config set-context <your_context> --namespace=pyf # avoiding type the namespace on each commands
```
<h2>Administration</h2>

<h3>Installation</h3>

1. <b>XXXXX</b>.
      <details><summary>Show</summary>

      ```
      XXXXX
      ```
      </details>

2. <b>Join Worker Nodes</b>.
      <details><summary>Show</summary>

      ```
      XXXXX
      ```
      </details>

<h3>Backup & Restore</h3>

<h3>Upgrade Kubernetes Cluster</h3>

<h3>Contexts</h3>

<h2>Security</h2>

<h3>Certificates</h3>

<h3>Roles</h3>

<h3>Service Account</h3>

<h2>Observability</h2>

<h3>JSONPath</h3>

<h2>Troubleshooting</h2>
