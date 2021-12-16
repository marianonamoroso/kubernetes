<img src="https://user-images.githubusercontent.com/8485060/146396141-6682bb2b-8712-465e-a0a1-241c99d88486.png" width=80 height="80"/>
<h1>Kubernetes</h1>
This repository contains helpful general use commands when working with Kubernetes (reference: https://github.com/StenlyTU/K8s-training-official). Also, you have kube-response tool giving you shortcuts for listing and exporting information of your nodes, pods and deployments via cli without memorizing some options with kubectl<br><br>
<i>FYI: We'll use the following alias: k=kubectl</i>
<h2>Core Concepts </h2>

1. <b>Create namespace called pyf</b>.
      <details><summary>Show</summary>

      ```
      k create ns pyf
      ```
      </details>
2. <b>Create two pods with busybox imagenamed busybox1 and busybox1 into the namespace called pyf. Also, you have to label them with the following syntax: application=backend</b>.
      <details><summary>Show</summary>

      ```
      k run nginx1 --image=nginx --namespace=pyf --labels=application=backend
      k run nginx2 --image=nginx --namespace=pyf --labels=application=backend
      k get pod -n pyf
      ```
      </details>
3. <b>Change pod nginx2 label to application=frontend.</b>
      <details><summary>Show</summary>

      ```
      k label pod nginx2 application=frontend --overwrite -n pyf
      k describe pod -n pyf nginx2 | grep -i label
      ```
      </details>
4. <b>Get only pods with label application=frontend from all namespaces.</b>
      <details><summary>Show</summary>

      ```
      k get pod -n pyf -l application=frontend
      k get pod --show-labels -n pyf #check all labels
      ```
      </details>
5. <b>Remove all pods to clean your namespace.</b>
      <details><summary>Show</summary>

      ```
      k delete pod -n pyf nginx{1,2}
      ```
      </details>  
6. <b>Remove all pods to clean your namespace.</b>
      <details><summary>Show</summary>

      ```
      k run messaging --image=redis:alpine --labels=tier=msg
      k get pod -n default --show-labels
      ```
      </details>  
      
      




