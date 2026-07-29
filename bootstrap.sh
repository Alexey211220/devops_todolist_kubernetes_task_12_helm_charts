#!/bin/bash

set -e

kind create cluster --name todoapp --config cluster.yml

kubectl wait --for=condition=Ready nodes --all --timeout=120s

kubectl taint nodes -l app=mysql app=mysql:NoSchedule

helm lint .infrastructure/helm-charts/todoapp

helm upgrade --install todoapp .infrastructure/helm-charts/todoapp

