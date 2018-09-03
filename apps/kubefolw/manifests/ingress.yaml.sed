apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: {{.name}} 
  namespace: {{.namespace}} 
spec:
  rules:
  - host: gmt.tflb.me 
    http:
      paths:
      - path: /
        backend:
          serviceName: tf-hub-lb 
          servicePort: 80 
  - host: gmt.tfjd.me 
    http:
      paths:
      - path: /
        backend:
          serviceName: tf-job-dashboard 
          servicePort: 80 
  - host: gmt.tfam.me 
    http:
      paths:
      - path: /
        backend:
          serviceName: ambassador 
          servicePort: 80 
