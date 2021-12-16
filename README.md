<img src="https://user-images.githubusercontent.com/8485060/146396141-6682bb2b-8712-465e-a0a1-241c99d88486.png" width=100 height="100"/>
<h1>Kubernetes</h1>
The goal of this tutorial is to give a helpful general use commands when working with Kubernetes.<br>
<h2>Core Concepts </h2>

1. Create namespace called challenge.
      <details><summary>Show</summary>

      ```
      kubectl create ns challenge
      ```
      </details>
2. Create two pods with busybox image named busybox1 and busybox1 into the namespace called challenge. Also, you have to label them with the following syntax: application=backend.



