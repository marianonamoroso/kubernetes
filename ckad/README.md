<img src="https://user-images.githubusercontent.com/8485060/147371404-edb634c8-d13c-4226-b632-b424bd999ad9.png" width=80 height=80/>
<h1>CKAD</h1>
This repository contains helpful use commands, exercises for preparing the CKAD. I used great public repos in order to practice the skills needed for doing the CKAD.<br><br>
<b>Exercises:</b><br> 

- https://github.com/StenlyTU/K8s-training-official
- https://github.com/dgkanatsios/CKAD-exercises

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

10. <b>Create a daemonset named ds-ckad with image httpd:latest and labels id=ds-ckad and uuid=1235-5555-2356-3212 in the pyf namespace with 100 millicore cpu and 100 mebibyte memory. Also, the pods should run on all nodes.</b> 
      <details><summary>Show</summary>

      ```
      k describe node master |grep -i taints # you can check the tolerations.
      vi ds-10.yaml
      ```
      ```
      apiVersion: apps/v1
      kind: DaemonSet
      metadata:
        name: ds-ckad
        namespace: pyf
        labels:
          id: ds-ckad
          uuid: 1235-5555-2356-3212
      spec:
        selector:
          matchLabels:
            id: ds-ckad
            uuid: 1235-5555-2356-3212
        template:
          metadata:
            labels:
              id: ds-ckad
              uuid: 1235-5555-2356-3212
          spec:
            containers:
            - name: ds-ckad 
              image: httpd:latest
              resources:
                requests:
                  cpu: 100m
                  memory: 100Mi
            tolerations:
              - key: node-role.kubernetes.io/master
                effect: "NoSchedule"
      ```
      ```
      k create -f ds-10.yaml
      k get daemonset.apps/ds-ckad -n pyf
      k get pod -n pyf -o wide |grep -i ds-ckad # you should see the pods on each node (also master)
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

17. <b>Create a deployment named deploy-critical with label severity=critical and 3 replicas. It should contain two containers, the first named container-1 with image nginx:latest and the second one named container-2 with image kubernetes/pause. You should run only two pods on the worker nodes and the third pod won't be scheduled (we have only two worker nodes).</b> 
      <details><summary>Show</summary>

      ```
      k create deployment deploy-critical --image=nginx:latest --replicas=3 --dry-run=client -o yaml > 17-deploy.yaml
      vi 17-deploy.yaml
      ```
      ```
      apiVersion: apps/v1
      kind: Deployment
      metadata:
        labels:
          severity: critical
        name: deploy-critical
      spec:
        replicas: 3
        selector:
          matchLabels:
            severity: critical
        strategy: {}
        template:
          metadata:
            labels:
              severity: critical
          spec:
            containers:
            - image: nginx:latest
              name: container-1
            - image: kubernetes/pause
              name: container-2
            affinity:
              podAntiAffinity:
                requiredDuringSchedulingIgnoredDuringExecution:
                - labelSelector:
                    matchExpressions:
                    - key: severity
                      operator: In
                      values:
                      - critical
                  topologyKey: kubernetes.io/hostname
      ```
      ```
      k create -f 17-deploy.yaml
      k get pod -o wide # you should see only two pods running
      ```
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

23. <b>Create a single pod of image httpd:latest. The pod should be named pod-schedule and the container should be named pod-schedule-container. It should only be scheduled on a master node.</b> 
      <details><summary>Show</summary>
      
      ```
      k get node
      k describe node master | grep -i Taints
      k get node master --show-labels # also, you can execute the following command: k describe  node master |grep -i labels -A 10
      ```
      ```      
      k run pod-schedule --image=httpd:latest --dry-run=client -o yaml > 23-pod.yaml
      vi 23-pod.yaml
      ```
      ```
      apiVersion: v1
      kind: Pod
      metadata:
        labels:
          run: pod-schedule
        name: pod-schedule
      spec:
        containers:
        - image: httpd:latest
          name: pod-schedule-container
        tolerations:        
        - effect: NoSchedule
          key: node-role.kubernetes.io/master
        nodeSelector:                       
          node-role.kubernetes.io/master: "" 
      ```
      ```
      k create -f 23-pod.yaml
      k get pod -o wide|grep -i pod-schedule
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
 
25. <b>Create a configmap anotherone with values var6=val6 and var7=val7. Load this configmap as an env variables into a nginx-sec pod.</b> 
       <details><summary>Show</summary>
       
       ```
       k create configmap anotherone --from-literal=var6=val6 --from-literal=var7=val7 --namespace=pyf      
       ```
       ```
       k run nginx-sec --image=nginx --namespace=pyf --dry-run=client -o yaml > 25-pod.yml
       vi 25-pod.yml      
       ```
       ```
       apiVersion: v1
       kind: Pod
       metadata:
         creationTimestamp: null
         labels:
           run: nginx-sec
         namespace: pyf
         name: nginx-sec
       spec:
         containers:
         - image: nginx
           name: nginx-sec
           env:
             - name: var6
               valueFrom:
                 configMapKeyRef:
                   name: anotherone
                   key: var6
             - name: var7
               valueFrom:
                 configMapKeyRef:
                   name: anotherone
                   key: var7        
       ```
       ``` 
       k create -f 25-pod.yml     
       ```       
       ```      
       k -n pyf exec -it nginx-sec -- env|grep -i var
       ```
       </details>    
       
26. <b>Create a configMap cmvolume with values var8=val8 and var9=val9. Load this as a volume inside an nginx-cm pod on path /etc/spartaa. Create the pod and 'ls' into the /etc/spartaa directory.</b> 
       <details><summary>Show</summary>
       
       ```
       k create configmap cmvolume --from-literal=var8=val8 --from-literal=var9=val9 --namespace=pyf  
       ```
       ```
       k run nginx-cm --image=nginx --namespace=pyf --dry-run=client -o yaml > 26-pod.yml
       vi 26-pod.yml      
       ```
       ```
       apiVersion: v1
       kind: Pod
       metadata:
         creationTimestamp: null
         labels:
           run: nginx-cm
         name: nginx-cm
         namespace: pyf
       spec:
         volumes:
           - name: config-volume
             configMap:
               name: cmvolume
         containers:
         - image: nginx
           name: nginx-cm
           volumeMounts:
             - name: config-volume
               mountPath: /etc/spartaa    
       ```
       ``` 
       k create -f 26-pod.yml     
       ```       
       ```      
       k exec -n pyf nginx-cm -it -- ls /etc/spartaa
       ```
       </details>       

27. <b>Create an nginx-requests pod with requests cpu=100m, memory=256Mi and limits cpu=200m, memory=512Mi.</b> 
       <details><summary>Show</summary>
       
       ```
       k run nginx-requests --namespace=pyf --image=nginx --dry-run=client -o yaml > 27-pod.yml
       ```
       ```
       vi 27-pod.yml      
       ```
       ```
       apiVersion: v1
       kind: Pod
       metadata:
         creationTimestamp: null
         labels:
           run: nginx-requests
         name: nginx-requests
         namespace: pyf
       spec:
         containers:
         - image: nginx
           name: nginx-requests
           resources:
             requests:
               memory: "256Mi"
               cpu: "100m"
             limits:
               memory: "512Mi"
               cpu: "200m"   
       ```
       ``` 
       k create -f 27-pod.yml     
       ```       
       ```      
       k describe pod/nginx-requests -n pyf 
       ```
       </details>           

28. <b>Create a secret called mysecret with values password=mypass and check its yaml.</b> 
       <details><summary>Show</summary>
       
       ```
       k create secret generic mysecret --from-literal=password=mypass --namespace=pyf
       k get secret/mysecret -n pyf
       k describe secret/mysecret -n pyf
             
       ```
       </details>        

29. <b>Create an nginx pod that mounts the secret mysecret in a volume on path /etc/foo.</b> 
       <details><summary>Show</summary>
       
       ```
       k run nginx-secret --image=nginx --namespace=pyf --dry-run=client -o yaml > 29-pod.yml
       vi 29-pod.yml      
       ```
       ```
       apiVersion: v1
       kind: Pod
       metadata:
         creationTimestamp: null
         labels:
           run: nginx-secret
         name: nginx-secret
         namespace: pyf
       spec:
         volumes:
         - name: secret
           secret:
             secretName: mysecret
         containers:
         - image: nginx
           name: nginx-secret
           volumeMounts:
           - name: secret
             mountPath: "/etc/foo"
             readOnly: true
       ```
       ```
       k create -f 29-pod.yml
       k describe pod nginx-secret -n pyf      
       ```       
       </details> 
      
<h2>Observability</h2>  
      
30. <b>Get the list of nodes in JSON format and store it in a file.</b> 
       <details><summary>Show</summary>
       
       ```
       k get node -o json      
       ```
       </details> 
      
31. <b>Get CPU/memory utilization for nodes.</b> 
       <details><summary>Show</summary>
       
       ```
       k top nodes     
       ```
       </details> 
 
32. <b>Create an nginx pod with a liveness probe that just runs the command ls. Check probe status.</b> 
       <details><summary>Show</summary>
       
       ```
       k run nginx-liveness --image=nginx --namespace=pyf --dry-run=client -o yaml > 32-pod.yml
       vi 32-pod.yml
       ```
       ``` 
       apiVersion: v1
       kind: Pod
       metadata:
         creationTimestamp: null
         labels:
           run: nginx-liveness
         name: nginx-liveness
         namespace: pyf
       spec:
         containers:
           - image: nginx
             name: nginx-liveness
             livenessProbe:
               exec:
                 command:
                 - ls     
       ```
       ``` 
       k create -f 32-pod.yml
       k get pod -n pyf      
       ```      
       </details>

32. <b>Create an nginx pod with a liveness probe that just runs the command ls. Check probe status.</b> 
       <details><summary>Show</summary>
       
       ```
       k run nginx-readiness --image=nginx --namespace=pyf --port=80 --dry-run=client -o yaml > 32-pod.yml
       vi 32-pod.yml
       ```
       ``` 
       apiVersion: v1
       kind: Pod
       metadata:
         creationTimestamp: null
         labels:
           run: nginx-readiness
         name: nginx-readiness
         namespace: pyf
       spec:
         containers:
         - image: nginx
           name: nginx-readiness
           ports:
           - containerPort: 80
           readinessProbe:
             httpGet:
               path: /
               port: 80     
       ```
       ``` 
       k create -f 32-pod.yml
       k get pod -n pyf      
       ```      
       </details>  

33. <b>Create a pod named not-ready-pod of image busybox. Configure a livenessprobe which simply runs "true". Also configure a readinessprobe which does check if the url http://svc-check:8080 is reachable executing the command curl or wget. 
Create a service named svc-check with the selector svc=ready. Finally, create second pod named ready-pod of image nginx with label svc=ready with the target port 8080. </b> 
       <details><summary>Show</summary>
       
       ```
       k run not-ready-pod --image=nginx --dry-run=client -o yaml -- echo "Hi I'm your POD" > 33-not-ready-pod.yaml
       vi 33-not-ready-pod.yaml   
       ```
       ``` 
       apiVersion: v1
       kind: Pod
       metadata:
         labels:
           run: not-ready-pod
         name: not-ready-pod
       spec:
         containers:
         - name: not-ready-pod
           image: nginx
           livenessProbe:
             exec:
               command:      
               - "true"
           readinessProbe:
             exec:
               command:
               - sh
               - -c
               - "wget -T2 -O- http://svc-check:8080"  
       ```
       ```
       k get pod not-ready-pod
       k describe pod not-ready-pod # svc-check doesn't exist yet
       ```
       ```
       k run ready-pod --image=nginx --port=80 --labels=svc=ready
       k expose pod ready-pod --target-port=80 --name=svc-check
       k describe svc svc-check
       ```
           
       </details>  
      
34. <b>Use JSON PATH query to retrieve the osImages of all the nodes.</b> 
       <details><summary>Show</summary>
       
       ```
       k get pod -n pyf -o jsonpath='{.items[*].spec.containers[*].image}{"\n"}'
       ```
       </details> 
      
<h2>Storage</h2>  
      
35. <b>Create a PersistentVolume of 1Gi, called 'myvolume-practice'. Make it have accessMode of 'ReadWriteOnce' and 'ReadWriteMany', storageClassName 'normal', mounted on hostPath '/etc/foo'. List all PersistentVolume</b> 
       <details><summary>Show</summary>
       
       ```
       vi 35-pv.yml
       ```
       ```
       apiVersion: v1
       kind: PersistentVolume
       metadata:
         name: myvolume-practice
       spec:
         capacity:
           storage: 1Gi
         volumeMode: Filesystem
         accessModes:
           - ReadWriteOnce
           - ReadWriteMany
         persistentVolumeReclaimPolicy: Recycle
         storageClassName: normal
         hostPath:
           path: /etc/foo
       ```
       ```
       k create -f 35-pv.yml
       k get pv
       ```      
       </details>   
      
36. <b>Create a PersistentVolumeClaim called 'mypvc-practice' requesting 400Mi with accessMode of 'ReadWriteOnce' and storageClassName of normal. Check the status of the PersistenVolume.</b> 
       <details><summary>Show</summary>
       
       ```
       vi 36-pv.yml
       ```
       ```
       apiVersion: v1
       kind: PersistentVolumeClaim
       metadata:
         name: mypvc-practice
         namespace: pyf
       spec:
         accessModes:
           - ReadWriteOnce
         volumeMode: Filesystem
         resources:
           requests:
             storage: 400Mi
         storageClassName: normal
       ```
       ```
       k create -f 36-pv.yml
       k get pvc -n pyf
       ```      
       </details>         
37. <b>Create a busybox pod with command 'sleep 3600'. Mount the PersistentVolumeClaim mypvc-practice to '/etc/foo'. Connect to the 'busybox' pod, and copy the '/etc/passwd' file to '/etc/foo/passwd'.</b> 
       <details><summary>Show</summary>
       
       ```
       k run busybox-pvc --image=busybox --namespace=pyf --dry-run=client -o yaml -- sleep 3600 > 37-pod.yml
       vi 37-pod.yml
       ```
       ```
       apiVersion: v1
       kind: Pod
       metadata:
         creationTimestamp: null
         labels:
           run: busybox-pvc
         name: busybox-pvc
         namespace: pyf
       spec:
         volumes:
           - name: vol-pvc
             persistentVolumeClaim:
               claimName: mypvc-practice
         containers:
         - args:
           - sleep
           - "3600"
           image: busybox
           name: busybox-pvc
           volumeMounts:
             - mountPath: "/etc/foo"
               name: vol-pvc
       ```
       ```
       k create -f 37-pod.yml 
       k get pod -n pyf
       k exec -it busybox-pvc -n pyf -- cp /etc/passwd /etc/foo/passwd      
       ```      
       </details>
      
38. <b>Create a second pod which is identical with the one you just created (use different name). Connect to it and verify that '/etc/foo' contains the 'passwd' file. Delete the pods.</b> 
       <details><summary>Show</summary>
       
       ```
       k run busybox-second-pvc --image=busybox --namespace=pyf --dry-run=client -o yaml -- sleep 3600 > 38-pod.yml
       vi 38-pod.yml
       ```
       ```
       apiVersion: v1
       kind: Pod
       metadata:
         creationTimestamp: null
         labels:
           run: busybox-second-pvc
         name: busybox-second-pvc
         namespace: pyf
       spec:
         volumes:
           - name: vol-pvc
             persistentVolumeClaim:
               claimName: mypvc-practice
         containers:
         - args:
           - sleep
           - "3600"
           image: busybox
           name: busybox-second-pvc
           volumeMounts:
             - mountPath: "/etc/foo/"
               name: vol-pvc
       ```
       ```
       k create -f 38-pod.yml 
       k get pod -n pyf
       k exec -it busybox-second-pvc -n pyf -- cat /etc/foo/passwd     
       ```      
       </details>
      
<h2>Security</h2>  
      
39. <b>Create busybox-user pod that runs sleep for 1 hour and has user ID set to 101. Check the UID from within the container.</b> 
       <details><summary>Show</summary>
       
       ```
       k run busybox-user --image=busybox --namespace=pyf --dry-run=client -o yaml -- sleep 3600 > 39-pod.yml
       vi 39-pod.yml
       ```
       ```
       apiVersion: v1
       kind: Pod
       metadata:
         creationTimestamp: null
         labels:
           run: busybox-user
         name: busybox-user
         namespace: pyf
       spec:
         securityContext:
           runAsUser: 101
         containers:
         - args:
           - sleep
           - "3600"
           image: busybox
           name: busybox-user
       ```
       ```
       k create -f 39-pod.yml 
       k get pod -n pyf
       k exec -it -n pyf busybox-user -- id -u
       ```      
       </details>   

40. <b>Create the YAML for an nginx pod that has capabilities "NET_ADMIN" and "SYS_TIME".</b> 
       <details><summary>Show</summary>
       
       ```
       k run nginx-sec-pod --image=nginx --namespace=pyf --dry-run=client -o yaml > 40-pod.yaml
       vi 40-pod.yml
       ```
       ```
       apiVersion: v1
       kind: Pod
       metadata:
         creationTimestamp: null
         labels:
           run: nginx-sec-pod
         name: nginx-sec-pod
         namespace: pyf
       spec:
         containers:
         - image: nginx
           name: nginx-sec-pod
           securityContext:
             capabilities:
               add: ["NET_ADMIN", "SYS_TIME"]
       ```
       ```
       k create -f 40-pod.yml 
       k get pod -n pyf
       k exec -it -n pyf nginx-sec-pod -- cat /proc/1/status # CapPrm:00000000aa0435fb | CapEff:00000000aa0435fb
       ```      
       </details>    
41. <b>Create a new service account with the name pvviewer-practice. Grant this Service account access to list all PersistentVolumes in the cluster by creating an appropriate cluster role called pvviewer-role-practice and ClusterRoleBinding called pvviewer-role-binding-practice.</b> 
       <details><summary>Show</summary>
       
       ```
       k create serviceaccount -n pyf pvviewer-practice
       k create clusterrole pvviewer-role-practice -n pyf --resource=pv --verb=list
       k create clusterrolebinding -n pyf pvviewer-role-binding-practice --clusterrole=pvviewer-role-practice --serviceaccount=pyf:pvviewer-practice
       ```
       ```
       k get -n pyf serviceaccount pvviewer-practice      
       k get -n pyf clusterrole pvviewer-role-practice       
       k describe clusterrolebinding pvviewer-role-binding-practice
       ```      
       </details>         

<h2>Networking</h2>  

42. <b>Create a pod with image nginx called nginx-1 and expose its port 80.</b> 
       <details><summary>Show</summary>
       
       ```
       k run nginx-1 --image=nginx --namespace=pyf --port=80 --expose
       k get pod/nginx-1 -n pyf
       k get service/nginx-1 -n pyf        
       ```
       ```      
       k describe service/nginx-1 -n pyf      
       k describe pod/nginx-1 -n pyf
       ```
       </details>            
 
43. <b>Get service's ClusterIP, create a temp busybox-1 pod and 'hit' that IP with wget.</b> 
       <details><summary>Show</summary>
       
       ```
       k get service -n pyf      
       k run --rm -it --image=busybox busybox-1 --namespace=pyf -- wget -O- $CLUSTER_IP:80       
       ```

       </details>   

44. <b>Convert the ClusterIP to NodePort for the same service and find the NodePort. Hit the service(create temp busybox pod) using Node's IP and Port.</b> 
       <details><summary>Show</summary>
       
       ```
       k get service nginx-1 -n pyf -o yaml > 44-service.yml
       vi 44-service.yml 
       ```
       ```
       apiVersion: v1
       kind: Service
       metadata:
         name: nginx-1
         namespace: pyf
       spec:
         ports:
         - port: 80
           protocol: TCP
           targetPort: 80
         selector:
           run: nginx-1
         sessionAffinity: None
         type: NodePort      
       ```      
       ```      
       k delete service nginx-1 -n pyf
       k create -f 44-service.yml      
       ```
       ```      
       k get service/nginx-1 -n pyf #NODE_PORT
       k get pod nginx-1 -n pyf -o wide #NODE_NAME 
       k get node -o wide #NODE_IP
       wget -O- $NODE_IP:$NODE_PORT     
       ```      

       </details>         
    
45. <b>Create an nginx-last deployment of 2 replicas, expose it via a ClusterIP service on port 80. Create a NetworkPolicy so that only pods with labels 'access: granted' can access the deployment.</b> 
       <details><summary>Show</summary>
       
       ```
       k create deployment nginx-last --image=nginx --replicas=2 --namespace=pyf --port=80      
       k expose deployment nginx-last --namespace=pyf --target-port=80
       k describe service/nginx-last -n pyf
       k get pod -n pyf --show-labels # app=nginx-last     
       vi 45-np.yml 
       ```
       ```
       apiVersion: networking.k8s.io/v1
       kind: NetworkPolicy
       metadata:
         name: np-nginx-last-pyf
         namespace: pyf
       spec:
         podSelector:
           matchLabels:
             app: nginx-last 
         policyTypes:
         - Ingress
         ingress:
         - from:
           - podSelector:
               matchLabels:
                 access: granted
           ports:
           - protocol: TCP
             port: 80     
       ```      
       ```      
       k create -f 45-np.yml
       k get service/nginx-last -n pyf # CLUSTER_IP
       ```
       ```
       k run busybox-temp --image=busybox --rm -it --namespace=pyf -- wget -O- $CLUSTER_IP:80 (you CANNOT connect to the pod)     
       k run busybox-temp --image=busybox --labels=access=granted --rm -it --namespace=pyf -- wget -O- $CLUSTER_IP:80  (you CAN connect to the pod)    
    
       ```      

       </details>           
 
46. <b>Create a pod with image nginx called nginx and expose its port 80. Confirm that ClusterIP has been created. Also check endpoints</b> 
       <details><summary>Show</summary>
       
       ```
       k run nginx --image=nginx --port 80 --expose -n pyf # also, you create the associated service
       ```
       ```
       k get service/nginx -n pyf      
       k get pod/nginx -n pyf    
       k describe service/nginx -n pyf # you can check the service type and endpoint associated with it    
       ``` 

      </details>
      
47. <b>Get service's ClusterIP, create a temp busybox pod and 'hit' that IP with wget.</b> 
       <details><summary>Show</summary>      
      
       ```
       k run temp --image=busybox --rm -it -n pyf -- sh 
       ```      
       ``` 
       wget -O- <CLUSTER_IP>:80 # if you have any problem, please restart your coredns deployment and try it again: k rollout restart deployment coredns --namespace kube-system
       exit      
       ```
       
       </details>
             
<h2>Challenging</h2>  

46. <b>Create an nginx pod called nginx-resolver using image nginx, expose it internally with a service called nginx-resolver-service. Test that you are able to look up the service and pod names from within the cluster. Use the image: busybox:1.28 for dns lookup.</b> 
       <details><summary>Show</summary>
       
       ```
       k run nginx-resolver --image=nginx --namespace=pyf
       k expose pod nginx-resolver --port=53 --target-port=53 --namespace=pyf --name=nginx-resolver-service
       k run --namespace=pyf --image=busybox:1.28 --rm -it busybox-temp-dns -- sh # nslookup nginx-resolver-service.pyf        
    
       ```      

       </details>

47. <b>List the InternalIP of all nodes of the cluster.</b> 
       <details><summary>Show</summary>
       
       ```
       kubectl get nodes -o jsonpath='{.items[*].metadata.name}{"\n"}{.items[*].status.addresses[?(@.type=="InternalIP")].address}{"\n"}'
       ```
       ```      
       k get node -o wide
       ```      

       </details>      

48. <b>Taint one worker node to be Unschedulable. Once done, create a pod called dev-redis with image redis:alpine to ensure workloads are not scheduled to the tainted node. Finally, create a new pod called prod-redis with image redis:alpine with toleration to be scheduled on the tainted node.</b> 
       <details><summary>Show</summary>
       
       ```
       k taint node worker2 spray=mortein:NoSchedule
       k run pod-taint --image=nginx --namespace=pyf
       k get pod pod-taint -n pyf -o wide # worker1    
       ```
       ```      
       k run pod-taint-toleration-redis --image=nginx --namespace=pyf --dry-run=client -o yaml> 48-pod.yml
       vi 48-pod.yml      
       ``` 
       ``` 
       apiVersion: v1
       kind: Pod
       metadata:
         creationTimestamp: null
         labels:
           run: pod-taint-toleration-redis
         name: pod-taint-toleration-redis
         namespace: pyf
       spec:
         tolerations:
         - key: "spray"
           operator: "Equal"
           value: "mortein"
           effect: "NoSchedule"
         containers:
         - image: redis
           name: pod-taint-toleration      
       ```
       ```
       k create -f 48-pod.yml 
       k get pod pod-taint-toleration -n pyf -o wide # worker2     
       ```
       ```      
       k taint node worker2 spray-
       ```      

       </details>         

49. <b>Create a Pod called redis-storage with image redis:alpine with a Volume of type emptyDir that lasts for the life of the Pod. Use volumeMount with mountPath = /data/redis.</b> 
       <details><summary>Show</summary>
       
       ```
       k run redis-storage --namespace=pyf --image=redis:alpine --dry-run=client -o yaml > 49-pod.yml
       vi 49-pod.yml 
       ```
       ```      
       apiVersion: v1
       kind: Pod
       metadata:
         creationTimestamp: null
         labels:
           run: redis-storage
         name: redis-storage
         namespace: pyf
       spec:
         volumes:
         - name: cache-volume
           emptyDir: {}
         containers:
         - image: redis:alpine
           name: redis-storage
           volumeMounts:
           - name: cache-volume
             mountPath: /data/redis     
       ``` 
       ``` 
       k create -f 49-pod.yml      
       k describe pod/redis-storage -n pyf|grep -i mounts -A1 
       ```
             
       </details>        
 
50. <b>Create a new deployment called nginx-deploy, with image nginx:1.16 and 1 replica. Record the version. Next upgrade the deployment to version 1.17 using rolling update. Make sure that the version upgrade is recorded in the resource annotation.</b> 
       <details><summary>Show</summary>
       
       ```
       k create deployment nginx-deploy --image=nginx:1.16 --replicas=1 --namespace=pyf
       k set image deployment nginx-deploy nginx=nginx:1.17 --namespace=pyf --record=true
       k describe deployment.apps/nginx-deploy -n pyf |grep -i image
       ```
       ```      
       k rollout undo deployment nginx-deploy -n pyf --record=true        
       k rollout history deployment nginx-deploy -n pyf      
       ```
      
       </details>

51. <b>Create a Pod with two containers, both with image busybox and command "echo hello; sleep 3600". Connect to the second container and run 'ls'.</b> 
       <details><summary>Show</summary>
       
       ```
       k run busybox-multi-container --image=busybox --namespace=pyf --dry-run=client -o yaml -- /bin/sh -c "echo hello; sleep 3600" > 52-pod.yml
       vi 52-pod.yml      
       ```
       ```
       apiVersion: v1
       kind: Pod
       metadata:
         labels:
           run: busybox-multi-container
         name: busybox-multi-container
         namespace: pyf
       spec:
         containers:
         - args:
           - /bin/sh
           - -c
           - echo hello; sleep 3600
           image: busybox
           name: busybox-container-1
         - args:
           - /bin/sh
           - -c
           - echo hello; sleep 3600
           image: busybox
           name: busybox-container-2      
       ```      
       ```
       k create -f 52-pod.yml
       k get -n pyf pod/busybox-multi-container      
       ```    
       ```
       k -n pyf exec busybox-multi-container -c busybox-container-2 -it -- ls      
       ```      
       </details>

52. <b>Create pod with nginx container exposed at port 80. Add a busybox init container which downloads a page using "wget -O /work-dir/index.html http://protectyourflag.com". Make a volume of type emptyDir and mount it in both containers. For the nginx container, mount it on "/usr/share/nginx/html" and for the initcontainer, mount it on "/work-dir". When done, get the IP of the created pod and create a busybox pod and run "wget -O- IP".</b> 
       <details><summary>Show</summary>
       
       ```
       k run multi-init-container --image=busybox --namespace=pyf --dry-run=client -o yaml -- /bin/sh -c 'wget -O /work-dir/index.html http://pyf.com' > 53-pod.yml
       vi 53-pod.yml      
       ```
       ```
       apiVersion: v1
       kind: Pod
       metadata:
         labels:
           run: multi-init-container
         name: multi-init-container
         namespace: pyf
       spec:
         volumes:
         - name: vol-empty-dir
           emptyDir: {}
         initContainers:
         - args:
           - /bin/sh
           - -c
           - wget -O /work-dir/index.html http://protectyourflag.com
           image: busybox
           name: multi-init-container-busybox-1
           volumeMounts:
           - name: vol-empty-dir
             mountPath: "/work-dir"
         containers:
         - name: multi-init-container-nginx-2
           image: nginx  
           volumeMounts:
           - name: vol-empty-dir
             mountPath: "/usr/share/nginx/html"
           ports:
           - containerPort: 80      
       ```      
       ```
       k create -f 53-pod.yml
       k get -n pyf pod/multi-init-container
       k describe pod -n pyf multi-init-container      
       ```    
       ```
       k run --image=busybox temp --rm -it --namespace=pyf -- wget -O- -T 5 10.44.0.9:80      
       ```      
       </details>    

52. <b>Create a static pod named static-pod on master node with the image nginx and have resource requests for 50m CPU and 30Mi memory. Then create a NodePort service named static-pod-service which exposes that static pod on port 80.</b> 
       <details><summary>Show</summary>
       
       ```
       k run static-pod --image=nginx --namespace=default --dry-run=client -o yaml > static-pod.yaml
       vi static-pod.yaml
       ```
       ```
       apiVersion: v1
       kind: Pod
       metadata:
         labels:
           run: static-pod
         name: static-pod
       spec:
         containers:
         - image: nginx
           name: static-pod
           resources:
             requests:
               memory: "30Mi"
               cpu: "50m"
       ```
       ```
       sudo vi /etc/kubernetes/manifests/static-pod.yaml # you have to create the yaml inside the path
       ```
       ```
       k get pod | grep -i static-pod
       ```      
       </details>    



<!-- 53. <b>Create a pod named multi-container with four containers, named c1, c2 and c3. There should be a volume attached to that pod and mounted into every container, but the volume shouldn't be persisted or shared with other pods. 
Container c1 should be of image nginx:latest and have the name of the node where its pod is running on value available as environment variable MY_NODE_NAME.
Container c2 should be of image busybox and write the output of the date command every second in the shared volume into file date.log. You can use "while true; do date >> /your/vol/path/date.log; sleep 1; done".
Container c3 should be of image busybox and constantly send the content of file date.log from the shared volume to stdout. You can use tail -f /your/vol/path/date.log for this.</b> 
      <details><summary>Show</summary>

      ```
      k run multi-container --image=nginx:latest --dry-run=client -o yaml > 53-multi-pod.yaml
      vi 53-multi-pod.yaml
      ```
      ```
      apiVersion: v1
      kind: Pod
      metadata:
        labels:
          run: multi-container
        name: multi-container
      spec:
        volumes:
          - name: pod-volume
            emptyDir: {}
        containers:
        - image: nginx:latest
          name: c1
          volumeMounts:
          - mountPath: /vol
            name: pod-volume
          env:
          - name: MY_NODE_NAME
            valueFrom:
              fieldRef:
                fieldPath: spec.nodeName
            name: pod-volume
        - image: busybox
          name: c2
          command: ["/bin/sh", "-c", "while true; do date >> /vol/date.log; sleep 1;done"]
          volumeMounts:
          - mountPath: /vol
            name: pod-volume
        - image: busybox
          name: c3
          command: ["/bin/sh", "-c", "tail -f /vol/date.log"]
          volumeMounts:
          - mountPath: /vol
            name: pod-volume
      ```
      ```
      k create -f 53-multi-pod.yaml
      k get pod multi-container
      k logs multi-container -c c3 # you have to see the logs of date.log
      ```
      </details>       -->
  