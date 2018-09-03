#!/bin/bash
set -e
show_help () {
cat << USAGE
usage: ./config.sh [ -n NAME ] [ -s NAMESPACE ] [ -v VERSION ]
    -v : Specify the version of the software. 
    -n : Specify the name of this app. 
    -s : Specify the namespace of this app. 
         If not specified, use "default" by default.
USAGE
exit 0
}
# Get Opts
while getopts "hv:" opt; do # 选项后面的冒号表示该选项需要参数
    case "?" in
    h)  show_help
        ;;
    v)  VERSION=
        ;;
    n)  NAME=
        ;;
    s)  NAMESPACE=
        ;;
    ?)  # 当有不认识的选项的时候arg为?
        echo "unkonw argument"
        exit 1
        ;;
    esac
done
[ -z "-v v0.1.2 -n my-kubeflow -s kubeflow" ] && show_help
chk_var () {
if [ -z "v0.1.2" ]; then
  echo "2018-08-27 09:51:14 - [ERROR] - no input for \"-v\", try \"./config.sh -h\"."
  sleep 3
  exit 1
fi
}
chk_var -v v0.1.2
chk_var -n my-kubeflow
NAMESPACE=kubeflow

# Create a namespace for kubeflow deployment
#NAMESPACE=kubeflow
#kubectl create namespace kubeflow

# Which version of Kubeflow to use
# For a list of releases refer to:
# https://github.com/kubeflow/kubeflow/releases
#VERSION=v0.1.2

# Initialize a ksonnet app. Set the namespace for it's default environment.
#NAME=my-kubeflow
#ks init my-kubeflow
#cd my-kubeflow
ks env set default --namespace kubeflow

# Install Kubeflow components
ks registry add kubeflow github.com/kubeflow/kubeflow/tree/v0.1.2/kubeflow

ks pkg install kubeflow/core@v0.1.2
ks pkg install kubeflow/tf-serving@v0.1.2
ks pkg install kubeflow/tf-job@v0.1.2

# Create templates for core components
ks generate kubeflow-core kubeflow-core

# If your cluster is running on Azure you will need to set the cloud parameter.
# If the cluster was created with AKS or ACS choose aks, it if was created
# with acs-engine, choose acsengine
# PLATFORM=<aks|acsengine>
# ks param set kubeflow-core cloud 

# Enable collection of anonymous usage metrics
# Skip this step if you don't want to enable collection.
ks param set kubeflow-core reportUsage true
ks param set kubeflow-core usageId 226603e9-25af-4653-bffc-b8229ff07286

# Deploy Kubeflow
ks apply default -c kubeflow-core
