0 Prerequisites 
===
* this directory is for spark-v2.2.0-kubernetes-0.5.0
* Java, and set enviroment variable JAVA_HOME
* a spark distribution with Kubernetes support, downloading from https://github.com/apache-spark-on-k8s/spark/releases
---
1 Installation 
===
1. 
	run 
```console
./run-me-first.sh
```
	to generate the service account and cluster role binding to use.
2.
	run
```console
./prepare-images.sh
```
	to get the images.

---
2 Testing
===
2.1 Java
---
```console
bin/spark-submit \
  --deploy-mode cluster \
  --class org.apache.spark.examples.SparkPi \
  --master k8s://https://${kube-master-ip}:${kube-master-port} \
  --conf spark.kubernetes.authenticate.driver.serviceAccountName=spark \
  --kubernetes-namespace default \
  --conf spark.executor.instances=5 \
  --conf spark.app.name=spark-pi \
  --conf spark.kubernetes.driver.docker.image=kubespark/spark-driver:v2.2.0-kubernetes-0.5.0 \
  --conf spark.kubernetes.executor.docker.image=kubespark/spark-executor:v2.2.0-kubernetes-0.5.0 \
  local:///opt/spark/examples/jars/spark-examples_2.11-2.2.0-k8s-0.5.0.jar
```

2.2 Python
---
```console
bin/spark-submit \
  --deploy-mode cluster \
  --master k8s://https://${kube-master-ip}:${kube-master-port} \
  --conf spark.kubernetes.authenticate.driver.serviceAccountName=spark \
  --kubernetes-namespace default \
  --conf spark.executor.instances=5 \
  --conf spark.app.name=spark-pi \
  --conf spark.kubernetes.driver.docker.image=kubespark/spark-driver-py:v2.2.0-kubernetes-0.5.0 \
  --conf spark.kubernetes.executor.docker.image=kubespark/spark-executor-py:v2.2.0-kubernetes-0.5.0 \
  --jars local:///opt/spark/examples/jars/spark-examples_2.11-2.2.0-k8s-0.5.0.jar \
  --py-files local:///opt/spark/examples/src/main/python/sort.py \
  local:///opt/spark/examples/src/main/python/pi.py 10
```

---
