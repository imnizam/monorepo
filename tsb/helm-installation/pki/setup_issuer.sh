#!/bin/bash
SCRIPTPATH=$(dirname "$0")

# If using self signed CA, create with the following script
# generate ca using "generate_ca.sh"
# Generate CA only once and reuse in all clusters to trus pki chain
# ${SCRIPTPATH}/generate_ca.sh

#Install cert manager 

${SCRIPTPATH}/install-cert-manager.sh

# create secert using previously generated ca, for cert-manager issuer
kubectl create secret tls root-ca -n cert-manager \
  --cert=${SCRIPTPATH}/ca/ca.crt \
  --key=${SCRIPTPATH}/ca/ca.key

# create issuer
cat << EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: root-ca
spec:
  ca:
    secretName: root-ca
EOF

