# Deploying Gitlab on Kubernetes

Manifests to deploy GitLab on Kubernetes  

## 0 Prerequisites:

1. All configurations are assuming deployment to namespace `gitlab`
2. Domain names used in this project are node ip and port.
3. Some pods are configured with local-volume persistent storage. To update.  

## 1 Deploying Gitlab

First, create a separate namespace for gitlab
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
