<img src="https://user-images.githubusercontent.com/8485060/146396141-6682bb2b-8712-465e-a0a1-241c99d88486.png" width=80 height="80"/>
<h1>Kubernetes</h1>
This repository contains helpful general use commands when working with Kubernetes. Also, you have kube-response tool giving you shortcuts for listing and exporting information of your nodes, pods and deployments via cli without memorizing some options with kubectl<br>
We'll use the following alias: k=kubectl
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
      k run nginx-1 --image=nginx --namespace=pyf --labels=application=backend
      k run nginx-2 --image=nginx --namespace=pyf --labels=application=backend
      k get pod -n pyf
      ```
      </details>
3. 



