<img src="https://user-images.githubusercontent.com/8485060/146396141-6682bb2b-8712-465e-a0a1-241c99d88486.png" width=80 height="80"/>
<h1>Kubernetes</h1>
This repository contains helpful use commands. Also, I created the kube-response tool giving you shortcuts for listing and exporting information of your nodes, pods and deployments via cli without memorizing some options with kubectl<br><br>
Exercises: https://github.com/StenlyTU/K8s-training-official<br>
Alias: k=kubectl
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
6. <b>Create a messaging pod using redis:alpine image with label set to tier=msg.</b>
      <details><summary>Show</summary>

      ```
      k run messaging --image=redis:alpine --labels=tier=msg --namespace=pyf
      k get pod -n default --show-labels -n pyf
      ```
      </details>  
7. <b>Create a service called messaging-service to expose the messaging application within the cluster on port 6379 and describe it.</b>
      <details><summary>Show</summary>

      ```
      k expose --name=messaging-service pod messaging --port=6379 --namespace=pyf
      k describe svc messaging-service -n pyf #ClusterIP
      ```
      </details>      
8. <b>Create a busybox-echo pod that echoes 'hello world' and exits. After that check the logs.</b> 
      <details><summary>Show</summary>

      ```
      k run busybox-echo --image=busybox --namespace=pyf -- echo "hello world"
      k logs busybox-echo -n pyf
      ```
      </details>       
9. <b>Create an nginx-test pod and set an env value as var1=val1. Check the env value existence within the pod.</b> 
      <details><summary>Show</summary>

      ```
      k run nginx-test --image=nginx --namespace=pyf --env=var1=val1
      k describe pod/nginx-test -n pyf | grep -i env -A1
      k exec -it nginx-test -n pyf -- env
      ```
      </details>     




