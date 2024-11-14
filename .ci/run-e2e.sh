#!/bin/bash

set -uexo pipefail
# shellcheck source=kind.env
source "$(dirname "$0")/kind.env"

kubectl create ns to-be-synced

waitforcm() {
  NAMESPACE="$1"
  CONFIGMAP="$2"
  KEY="${3:-}"
  timeout=60
  end=$((SECONDS + timeout))

  while (( SECONDS < end )); do
    if kubectl get cm -n "$NAMESPACE" "$CONFIGMAP" &> /dev/null; then
      echo "ConfigMap found"
      if [[ -n "${KEY}" ]]; then
        if kubectl get cm -n "$NAMESPACE" "$CONFIGMAP" -o json | jq -re .data."$KEY" &>/dev/null ; then
          echo "variable $KEY found in ConfigMap"
          break
        fi
      else 
        break
      fi
    fi
    sleep 1
  done

  if (( SECONDS >= end )); then
    echo "Timed out waiting for ConfigMap"
    exit 1
  fi

}

waitforcm default to-sync
waitforcm to-be-synced to-sync

kubectl apply -f ./.ci/configmap-v2.yaml
waitforcm default to-sync bar
