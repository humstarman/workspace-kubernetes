## 0 Prerequisites
	the version of kubeflow is v0.1.2
	Before installing kubeflow, following are needed:
* ansible
* kubernetes
* ksonnet 
<div>
and, the installation of ksonnet can be implemeted as:
</div>
<div>
1. download binary file from github
</div>
<div>
2. unzip and cp the binary file to $PATH
</div>

---
## 1 Generate my-kubeflow directory
	run:
```console
./init.sh
```

---
## 2 Prepare images
	for some reasons, one can not get images directly.

---
## 3 Pull the images and rename
	run:
```console
./pull-and-tag.sh
```

---
## 4 deploy tensorflow on kubernetes
1. cd to my-kubeflow directory
2. run:
```console
./run.sh
```

---
