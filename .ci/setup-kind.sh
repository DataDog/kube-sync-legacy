#!/usr/bin/env bash

# shellcheck source=kind.env
source "$(dirname "$0")/kind.env"

set -xe
if ! docker network inspect kind; then
  docker network create kind
fi

# If the cluster already exists, replace it
if kind get clusters | grep -q "^$KIND_CLUSTER_NAME$" ; then
  kind delete cluster --name "$KIND_CLUSTER_NAME"
fi
kind create cluster --name "$KIND_CLUSTER_NAME" --wait 5m

# Avoid overriding our kubeconfig when running locally
#KINDCONFIG=$(mktemp)
if [ "$CI" = "true" ] ; then
  kind get kubeconfig --name "$KIND_CLUSTER_NAME" > "$KUBECONFIG"
else 
  KINDCONFIG=$(mktemp)
  kind get kubeconfig --name "$KIND_CLUSTER_NAME" > "$KINDCONFIG" 
  KUBECONFIG="$KUBECONFIG:$KINDCONFIG" kubectl config view --raw --flatten > "$KUBECONFIG"
  kubectl config use-context "kind-$KIND_CLUSTER_NAME" 
fi

# Load the artifacts from the previous steps, or build the docker image
if ! docker images | grep -q kube-sync:local ; then 
  (
  cd "$(dirname "$0")/.."
  make kube-sync-docker
  )
fi
kind load docker-image kube-sync:local --name "${KIND_CLUSTER_NAME}"
