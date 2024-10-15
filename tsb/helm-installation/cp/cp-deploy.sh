#!/bin/bash
SCRIPTPATH=$(dirname "$0")

# helm based TSB controlplane installation
# Following steps are for TSB CP installation in k8s cluster
####################################################
# STEP-1
####################################################
# add the helm repo
helm repo add tetrate-tsb-helm 'https://charts.dl.tetrate.io/public/helm/charts/'
helm repo update
# list the available version 
helm search repo tetrate-tsb-helm -l

####################################################
# STEP-2
####################################################
# setup ca , cert-manmager and issuers , go to pki dirs and run setup_issuers.sh
#  ${SCRIPTPATH}/../pki/setup_issuer.sh

 ####################################################
# STEP-3
####################################################

#setup secrets
# Make sure tctl login is done
#Generate secrets

export REGION="ap-south-1"
export CP_CLUSTER="tsbtest"
export ORG="demo"
export HUB="imnizam.docker.io"
export TAG="1.8.2"

tctl x status org $ORG
if [[ $? != 0 ]];then
    echo "Please do tctl login first... \n"
    exit 1
fi

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
  network: tier2
  tokenTtl: "8760h"
  locality:
    region: $REGION
EOF

#generate cert for CP
# make sure elastic path and ca should of front envoy
tctl x cluster-install-template $CP_CLUSTER > ${SCRIPTPATH}/cp-values.yaml

kubectl create ns istio-system

cat << EOF | kubectl apply -f -
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: cacerts
  namespace: istio-system
spec:
  secretName: cacerts
  duration: "2160h"
  renewBefore: "24h"
  commonName: istiod.istio-system.svc
  isCA: true
  usages:
    - digital signature
    - key encipherment
    - cert sign
  dnsNames:
    - istiod.istio-system.svc
  issuerRef:
    name: root-ca
    kind: ClusterIssuer
EOF

sleep 20

helm upgrade --install cp tetrate-tsb-helm/controlplane \
  --namespace istio-system --create-namespace \
  --timeout 5m \
  -f "${CP_CLUSTER}-values.yaml" \
  --set image.registry="${HUB}" \
  --set image.tag="${TAG}" \
  --set spec.hub="${HUB}" \

sleep 20

helm upgrade --install dp tetrate-tsb-helm/dataplane \
  --namespace istio-gateway --create-namespace \
  --set image.registry="${HUB}" \
  --set image.tag="${TAG}"
