## Register the runner

```bash
kubectl run -it runner-registrator --image=gitlab/gitlab-runner:latest --restart=Never -- register
```
