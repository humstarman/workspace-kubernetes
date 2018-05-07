#!/bin/bash

# Create a namespace for kubeflow deployment
NAMESPACE=kubeflow
kubectl create namespace ${NAMESPACE}

# Which version of Kubeflow to use
# For a list of releases refer to:
# https://github.com/kubeflow/kubeflow/releases
VERSION=v0.1.2

# Initialize a ksonnet app. Set the namespace for it's default environment.
APP_NAME=my-kubeflow
ks init ${APP_NAME}

# cp the deployment script into the ${APP_NAME} directory
cp ./cp-to-kubeflow-then-run.sh ${APP_NAME}
