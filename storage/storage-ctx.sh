#!/bin/bash

kubectl config set-context storage \
	--cluster=kubernetes \
	--user=admin \
	--namespace=storage
