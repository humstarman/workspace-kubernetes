# Introduce NFS as persistence volumes for Kubernetes

## 1 install a NFS node
as instance:  
```
yum install -y rpc-bind nfs-utils
```
if the nfs directory is set to `/media/docker`:  
```
mkdir -p /media/docker
```
configure:  
```
cat > /etc/exports << EOF
/media/docker        *(no_root_squash,rw,sync,no_subtree_check)
```
then, at the NFS node, start NFS serivce:
```
systemctl daemon-reload
systemctl enable nfs
systemctl restart nfs
```

## 2 deployment
prepare nfs-controller.yaml:
```
kind: Deployment
apiVersion: extensions/v1beta1
metadata:
  name: nfs-client-provisioner
spec:
  replicas: 1
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: nfs-client-provisioner
    spec:
      serviceAccountName: nfs-client-provisioner
      containers:
        - name: nfs-client-provisioner
          image: quay.io/external_storage/nfs-client-provisioner:latest
          volumeMounts:
            - name: nfs-client-root
              mountPath: /persistentvolumes
          env:
            - name: PROVISIONER_NAME
              value: fuseim.pri/ifs
            - name: NFS_SERVER
              value: {{.nfs.ip}}
            - name: NFS_PATH
              value: /media/docker
      volumes:
        - name: nfs-client-root
          nfs:
            server: {{.nfs.ip}}
            path: /media/docker
``` 
replace {{.nfs.ip}} with the actual IP address of NFS node;  
prepare rbac.yaml:
```
apiVersion: v1
kind: ServiceAccount
metadata:
  name: nfs-client-provisioner

---

kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: nfs-client-provisioner-runner
rules:
  - apiGroups: [""]
    resources: ["persistentvolumes"]
    verbs: ["get", "list", "watch", "create", "delete"]
  - apiGroups: [""]
    resources: ["persistentvolumeclaims"]
    verbs: ["get", "list", "watch", "update"]
  - apiGroups: ["storage.k8s.io"]
    resources: ["storageclasses"]
    verbs: ["get", "list", "watch"]
  - apiGroups: [""]
    resources: ["events"]
    verbs: ["list", "watch", "create", "update", "patch"]

---

kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: run-nfs-client-provisioner
subjects:
  - kind: ServiceAccount
    name: nfs-client-provisioner
    namespace: default
roleRef:
  kind: ClusterRole
  name: nfs-client-provisioner-runner
  apiGroup: rbac.authorization.k8s.ior
```
prepare storageclass.yaml:  
```
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: managed-nfs-storage
provisioner: fuseim.pri/ifs
```
Then, run:  
```
kubectl create -f rbac.yaml -f bfs-controller.yaml -f storageclass.yaml
```

## 3 test
run:  
```
kubectl create -f test-claim.yaml -f test-pod.yaml
```
