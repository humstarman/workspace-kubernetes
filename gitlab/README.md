# 将 GitLab 部署到 Kubernetes 集群上

本项目展示，如何将一个常见的多组件工作负载（在本例中是 GitLab）部署到 Kubernetes 集群上。GitLab 因其基于 Git 的代码跟踪工具而流行。GitLab 代表着一种典型的多层应用程序，每个组件都拥有自己的容器。微服务容器将用于 Web 层，状态/作业数据库使用 Redis 和 PostgreSQL 作为数据库。  


1.用户通过 Web 接口或通过将代码推送到 GitHub 存储库来与 GitLab 交互。GitLab 容器运行 NGINX 和 gitlab-workhorse 背后的主要 Ruby on Rails 应用程序，gitlab-workhorse 是一个针对大型 HTTP 请求的逆向代理，比如文件下载和 Git 推送/拉取请求。在通过 HTTP/HTTPS 提供存储库时，GitLab 利用 GitLab API 来解决授权和访问，并提供 Git 对象。

2.经过身份验证和授权后，GitLab Rails 应用程序将传入的作业、作业信息和元数据放在 Redis 作业队列上，该作业队列充当着一个非持久数据库。

3.存储库创建于本地文件系统中。

4.用户创建用户、角色、合并请求、组等信息 - 所有这些信息然后存储在 PostgreSQL 中。

5.用户运行 Git shell 来访问存储库。

## 目标
这个场景提供以下任务的操作说明和经验：

- 构建容器并将它们存储在容器注册表中
- 使用 Kubernetes 创建本地持久卷来定义持久磁盘
- 使用 Kubernetes pod 和服务部署容器
- 将一个分布式 GitLab 部署到 Kubernetes 上

#### 步骤

[使用 Kubernetes 创建服务和部署](#1-use-kubernetes-to-create-services-and-deployments-for-gitlab-redis-and-postgresql)

#### 使用 Kubernetes 为 GitLab、Redis 和 PostgreSQL 创建服务并执行部署

运行 `kubectl` 命令确保您的 Kubernetes 集群可供访问。  

```bash
$ kubectl get nodes
NAME             STATUS    AGE       VERSION
x.x.x.x          Ready     17h       v1.5.3-2+be7137fd3ad68f
```

> 备注：如果这一步失败，请参阅 [Minikube](https://kubernetes.io/docs/getting-started-guides/minikube) 或 [IBM Bluemix Container Service](https://console.ng.bluemix.net/docs/containers/cs_troubleshoot.html#cs_troubleshoot) 上的故障排除文档。

##### 在容器中使用 PostgreSQL

如果使用容器映像来运行 PostgreSQL，可对您的 Kubernetes 集群运行以下命令。

```bash
$ kubectl create -f local-volumes.yaml
$ kubectl create -f postgres.yaml
$ kubectl create -f redis.yaml
$ kubectl create -f gitlab.yaml
```

创建所有这些服务和部署后，等待 3 到 5 分钟。可以在 Kubernetes UI 上检查部署状态。运行 kubectl proxy 并访问 URL 'http://127.0.0.1:8001/ui  '，以检查 GitLab 容器何时准备就绪。

> 备注：对于`local-volumes`，切勿提前手动创建文件夹。
