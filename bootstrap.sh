#!/bin/bash

set -e

kind create cluster --name todoapp --config cluster.yml

kubectl wait --for=condition=Ready nodes --all --timeout=120s

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

kubectl wait \
  --namespace ingress-nginx \
  --for=condition=Ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=180s

kubectl taint nodes -l app=mysql app=mysql:NoSchedule

helm lint .infrastructure/helm-chart/todoapp

helm upgrade --install todoapp .infrastructure/helm-chart/todoapp

kubectl get all,cm,secret,ing -A > output.log