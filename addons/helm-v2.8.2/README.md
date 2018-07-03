0 install helm
===
	download helm from github, and
	cp the binary file to /usr/local/bin
1 create serviceAccount and clusterRoleBinding for tiller
===
```console
kubectl create -f rbac.yml
```
2 run the tiller
===
```console
helm init -i lowyard/kubernetes-helm-tiller:v2.8.2 --stable-repo-url https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts
```
3 patch the deployment of tiller
===
```console
./config-tiller.sh
```


