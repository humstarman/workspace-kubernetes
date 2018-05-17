# Deploying Gitlab on Kubernetes

Manifests to deploy GitLab on Kubernetes  

## 0 Prerequisites:

1. All configurations are assuming deployment to namespace `gitlab`
2. Domain names used in this project are node ip and port.
3. Some pods are configured with local-volume persistent storage. To update.  

## 1 Deploying Gitlab

First, create a separate namespace for Gitlab
```bash
kubectl create -f gitlab-core/namespace.yaml
kubectl create -f gitlab-core/local-volumes.yaml
```

Deploy PostgreSQL and Redis
```bash
kubectl create -f gitlab-core/postgres.yaml
kubectl create -f gitlab-core/redis.yaml
```

Before deploying Gitlab, some extra works are requiered.  
On Kubernetes, Gitlab can serve in forms of 
- {Container_IP}:{Container_Port} 
- {SVC_IP}:{SVC_Port} 
- {NODE_IP}:{NODE_Port}  
 
As one can deploy ingress controller ahead of Gitlab,  
Gitlab also can use ingress rules to serve.  
By defalut, the `external_url` field of Gitlab is set as a site url.  
Therefore, DNS is critical. Normally, we write the `/etc/hosts`.  
But, in practice, if intergrating with CI implemented by Gitlab-runner,  
a Gitlab-runner may run a docker container to work.  
In this above circumstance, the runned docker container cannot resolve the `external_url` of Gitlab.  
The solution we used is to set the `external_url` in the form of  `http://{Node_IP}:{Node_Port}`.  

On Kubernetes. Gitlab-core service is schedlued by `kube-schedluer`; so in a cluster,  
it is hard to tell the node where the pod of Gitlab resides.  
To achieve this, we label the node, and introduce `NodeSelector` filed to `gitlab-core/gitlab.yaml`.  

Label the node to carry Gitlab  
```bash
kubectl label node {Node_Name} gitlab=true
```

Also, you can label other nodes as
```bash
kubectl label node {Other_Node_Name} gitlab=false
```

Accordingly, modify  `gitlab-core/gitlab.yaml` in two segment  
1. set the value `GITLAB_OMNIBUS_CONFIG` in `.spec.template.spec.containers[0].env` as `http://{Node_IP}:{Node_Port}`
2. in `.spec.template.spec` add `nodeSelector` filed with value `gitlab: "true"`  

Then, deploy Gitlab
```bash
kubectl label node {Other_Node_Name} gitlab=false
```

## 2 Deploying Gitlab-runner

To implement CIi, a exector is needed.  
In this project, we use Gitlab-runner.  
GitLab Runner supports several executors: 
- virtualbox
- docker+machine
- docker-ssh+machine
- docker
- docker-ssh
- parallels
- shell
- ssh  
Here, we use docker as the executor. 