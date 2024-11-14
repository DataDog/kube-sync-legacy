#!/bin/bash

set -uexo pipefail
# shellcheck source=kind.env
source "$(dirname "$0")/kind.env"

kubectl apply -f ./examples/deployment.yaml
