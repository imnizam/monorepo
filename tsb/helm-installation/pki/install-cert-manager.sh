#!/bin/bash
#https://istio.io/latest/docs/tasks/security/cert-management/custom-ca-k8s/
echo -e "Installing cert manager \n"
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm upgrade --install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.9.1 \
  --set featureGates="ExperimentalCertificateSigningRequestControllers=true" \
  --set installCRDs=true