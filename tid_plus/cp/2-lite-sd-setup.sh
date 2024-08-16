#!/usr/bin/env bash

set -x

CLUSTER="${CLUSTER:-"pod-cluster"}"
HUB="${HUB:-"docker.io/imnizam"}"
RELEASE_NAME="${RELEASE_NAME:-"tis-plus-cp"}"
NAMESPACE="${NAMESPACE:-"tis-plus-system"}"
MP_HOST="${MP_HOST:-"tsb.tetrate.io"}"
TAG=${TAG:-"26e7773a9e6c872cb418a38a209740f2be892456"}
HELM_PKG=${HELM_PKG:-"controlplane-1.10.0-dev+26e7773a9.tgz"}

helm upgrade --install "${RELEASE_NAME}" "${HELM_PKG}" \
  --namespace "${NAMESPACE}" --create-namespace \
  -f "${CLUSTER}-values.yaml" \
  --set image.registry="${HUB}" \
  --set image.tag="${TAG}" \
  --set spec.mode="OBSERVE" \
  --set operator.enableObserveMode=true \
  --set operator.deletionProtection="disabled"
