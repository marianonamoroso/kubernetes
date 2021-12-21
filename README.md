<img src="https://user-images.githubusercontent.com/8485060/146396141-6682bb2b-8712-465e-a0a1-241c99d88486.png" width=80 height="80"/>
<h1>Kubernetes</h1>
This repository contains helpful use commands. Also, I created the kube-response tool giving you shortcuts for listing and exporting information of your nodes, pods and deployments via cli without memorizing some options with kubectl<br>

<b>Exercises:</b> https://github.com/StenlyTU/K8s-training-official

<h2>Variables & Useful Stuff</h2>

```
alias k='kubectl'
export do='—dry-run=client -o yaml'
kubectl config set-context <your_context> --namespace=pyf # avoiding type the namespace on each commands
```
<h2>Core Concepts</h2>

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

<h2>Deployments</h2>

10. <b>Create a deployment named hr-app using the image nginx:1.18 with 2 replicas.</b> 
      <details><summary>Show</summary>

      ```
      k create deployment hr-app --image=nginx:1.18 --replicas=2 --namespace=pyf
      k get -n pyf deployment.apps/hr-app
      ```
      </details> 
11. <b>Scale hr-app deployment to 3 replicas.</b> 
      <details><summary>Show</summary>

      ```
      k scale deployment hr-app -n pyf --replicas=3
      k get -n pyf deployment.apps/hr-app
      ```
      </details>
12. <b>Update the hr-app image to nginx:1.19.</b> 
      <details><summary>Show</summary>

      ```
      k set image deployments/hr-app -n pyf nginx=nginx:1.19
      k describe deployments/hr-app -n pyf | grep -i image
      ```
      </details>      
13. <b>Check the rollout history of hr-app and confirm that the replicas are OK.</b> 
      <details><summary>Show</summary>

      ```
      k set image deployments/hr-app -n pyf nginx=nginx:1.19
      k describe deployments/hr-app -n pyf | grep -i image
      k get deployment hr-app -n pyf
      k get pod -n pyf
      ```
      </details>       
14. <b>Undo the latest rollout and verify that new pods have the old image (nginx:1.18)</b> 
      <details><summary>Show</summary>

      ```
      k rollout undo deployment hr-app -n pyf
      k rollout status deployment hr-app -n pyf
      k describe deployment -n pyf hr-app | grep -i image
      k get deployment -n pyf
      k get pod -n pyf
      ```
      </details>     
15. <b>Do an update of the deployment with a wrong image nginx:1.91 and check the status.</b> 
      <details><summary>Show</summary>

      ```
      k set image deployment hr-app -n pyf nginx=nginx:1.91
      k rollout status -n pyf deployment hr=app
      k get pod -n pyf
      k describe pod -n pyf <pod_name> #Error: ErrImagePull
      ```
      </details>          
16. <b>Return the deployment to working state and verify the image is nginx:1.19.</b> 
      <details><summary>Show</summary>

      ```
      k rollout undo deployment hr-app -n pyf 
      k rollout status deployment hr-app -n pyf
      k get pod -n pyf
      k describe pod -n pyf | grep -i image:
      ```
      </details>
<h2>Scheduling</h2>
      
17. <b>Shedule a nginx pod on specific node using NodeName.</b> 
      <details><summary>Show</summary>

      ```
      k run nginx-worker1 --image=nginx --namespace=pyf --dry-run=client -o yaml > nginx-nodename.yml
      vi nginx-nodename.yml # nodeName: worker1
      k apply -f nginx-nodename.yml 
      k get pods -n pyf -o wide |grep -i nginx-worker1
      ```
      </details>      
18. <b>Schedule a nginx pod based on node label using nodeSelector.</b> 
      <details><summary>Show</summary>

      ```
      k label node worker1 nodeselector=pyf
      k get nodes --show-labels
      k run nginx-nodeselector --image=nginx --namespace=pyf --dry-run=client -o yaml > nginx-nodeselector.yml
      vi nginx-nodeselector.yml # nodeSelector: nodeselector: pyf
      k apply -f nginx-nodeselector.yml
      k get pod -n pyf -o wide
      ```
      </details>  
19. <b>Taint a node with key=spray, value=mortein and effect=NoSchedule. Check that new pods are not scheduled on it.</b> 
      <details><summary>Show</summary>

      ```      
      k taint node worker1 spray=mortein:NoSchedule
      k run pod-taint --image=nginx --namespace=pyf
      k get pods -o wide -n pyf
      ```
      </details>   
20. <b>Create another pod called nginx-toleration with nginx image, which tolerates the above taint.</b> 
      <details><summary>Show</summary>
      
      ```
      # podSpec
      tolerations:
      - key: "spray"
        operator: "Equal"
        value: "mortein"
        effect: "NoSchedule"
      ```
      ```      
      k apply -f pod-toleration.yml
      k get pod -n pyf -o wide
      k taint node worker1 spray- #untainted
      ```
      </details>         
      
21. <b>Create a DaemonSet using image fluentd-elasticsearch:1.20.</b> 
      <details><summary>Show</summary>

      ```
      apiVersion: apps/v1
      kind: DaemonSet
      metadata:
        labels:
          app: elastic-search
        name: elastic-search
        namespace: pyf
      spec:
        selector:
          matchLabels:
            app: elastic-search
        template:
          metadata:
            labels:
              app: elastic-search
          spec:
            containers:
            - image: k8s.gcr.io/fluentd-elasticsearch:1.20
              name: fluentd-elasticsearch      
      ```      
      ```      
      k apply -f demonset.yml
      k get ds -n pyf
      k get pod -n pyf      
      ```
      </details>        
      
22. <b>Add label color=blue to one node and create nginx deployment called blue with 5 replicas and node Affinity rule to place the pods onto the labeled node.</b> 
      <details><summary>Show</summary>
      
      ```
      k label node worker1 color=blue      
      k create deployment blue --image=nginx --namespace=pyf --replicas=5 --dry-run=client -o yaml > 22-deployment.yml      
      ```
      ```
      apiVersion: apps/v1
      kind: Deployment
      metadata:
        creationTimestamp: null
        labels:
          app: blue
        name: blue
        namespace: pyf
      spec:
        replicas: 5
        selector:
          matchLabels:
            app: blue
        strategy: {}
        template:
          metadata:
            creationTimestamp: null
            labels:
              app: blue
          spec:
            affinity:
              nodeAffinity:
                requiredDuringSchedulingIgnoredDuringExecution: # pod will get scheduled only on a node that has a color=blue label
                  nodeSelectorTerms:
                  - matchExpressions:
                    - key: color
                      operator: In
                      values:
                      - blue   
            containers:
            - image: nginx
              name: nginx
              resources: {}      
       ```      
       ```
       k apply -f 22-deployment.yml
       k get pods -n pyf -o wide
       ```
       </details>
      
<h2>Configurations</h2>
      
23. <b>Create a configmap named my-config with values key1=val1 and key2=val2. Check it's values.</b> 
       <details><summary>Show</summary>
       
       ```      
       k create configmap my-config --from-literal=key1=val1 --from-literal=key2=val2 --namespace pyf
       k describe configmap/my-config -n pyf
       ```
       </details>  

24. <b>Create a configMap called opt with value key5=val5. Create a new nginx-opt pod that loads the value from key key5 in an env variable called OPTIONS.</b> 
       <details><summary>Show</summary>
       
       ```
       k create configmap opt --from-literal=key5=val5 --namespace=pyf      
       ```
       ```
       k run nginx-opt --image=nginx --namespace=pyf --dry-run=client -o yaml > 24-pod.yml
       vi 24-pod.yml      
       ```
       ```
       apiVersion: v1
       kind: Pod
       metadata:
         creationTimestamp: null
         labels:
           run: nginx-opt
         name: nginx-opt
         namespace: pyf
       spec:
         containers:
         - image: nginx
           name: nginx-opt
           env:
             - name: OPTIONS
               valueFrom:
                 configMapKeyRef:
                   name: opt
                   key: key5      
       ```
       ``` 
       k create -f 24-pod.yml      
       ```       
       ```      
       k -n pyf exec -it nginx-opt -- env|grep -i OPTIONS
       ```
       </details>       
      
      
