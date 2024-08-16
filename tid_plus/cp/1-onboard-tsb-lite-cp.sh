#!/usr/bin/env bash

set -x

CP_CLUSTER="pod-cluster"
ORG="tetrate"

# create cluster in TSB
cat << EOF | tctl apply -f -
apiVersion: api.tsb.tetrate.io/v2
kind: Cluster
metadata:
  displayName: $CP_CLUSTER
  name: $CP_CLUSTER
  organization: $ORG
spec:
  displayName: $CP_CLUSTER
  tier1Cluster: false
  tokenTtl: "8760h"
EOF

tctl x cluster-install-template "${CP_CLUSTER}" > "${CP_CLUSTER}-values.yaml"
