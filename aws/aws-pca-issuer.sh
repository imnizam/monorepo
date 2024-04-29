#!/bin/bash

export PCA_ARN="arn:aws:acm-pca:us-west-2:123456789:certificate-authority/abcdef123"
export CLUSTER="dev-eks"
export REGION="us-west-2"
#install cert manager
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

#install aws pca issuer

kubectl create namespace aws-pca-issuer
helm repo add awspca https://cert-manager.github.io/aws-privateca-issuer
helm repo update
helm upgrade --install awspca-issuer awspca/aws-privateca-issuer --namespace aws-pca-issuer

#setup IAM role for service account

# get cluster api endpoint
oidc_id=$(aws --region $REGION eks describe-cluster --name $CLUSTER --query "cluster.identity.oidc.issuer" --output text | cut -d '/' -f 5)
aws iam list-open-id-connect-providers | grep $oidc_id
if [ $? -ne 0 ];then
    eksctl utils associate-iam-oidc-provider --cluster=$CLUSTER --region $REGION --approve
fi

cat <<EOF > /tmp/pca-issuer-policy.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "awspcaissuer",
            "Action": [
                "acm-pca:DescribeCertificateAuthority",
                "acm-pca:GetCertificate",
                "acm-pca:IssueCertificate"
            ],
			"Effect": "Allow",
            "Resource": "${PCA_ARN}"
        }       
    ]
}
EOF

export iam_policy="${CLUSTER}-aws-pca-issuer-policy"
aws iam create-policy --policy-name $iam_policy --policy-document file:///tmp/pca-issuer-policy.json

export account_id=$(aws sts get-caller-identity --query "Account" --output text)
export oidc_provider=$(aws eks describe-cluster --name $CLUSTER --region $REGION --query "cluster.identity.oidc.issuer" --output text | sed -e "s/^https:\/\///")
export namespace="aws-pca-issuer"
export service_account="awspca-issuer-aws-privateca-issuer"
export pca_issuer_deploy="awspca-issuer-aws-privateca-issuer"
export iam_role="${CLUSTER}-aws-pca-issuer-role"


cat <<EOF > /tmp/trust-relationship.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${account_id}:oidc-provider/${oidc_provider}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "$oidc_provider:aud": "sts.amazonaws.com",
          "$oidc_provider:sub": "system:serviceaccount:$namespace:$service_account"
        }
      }
    }
  ]
}
EOF

aws iam create-role --role-name $iam_role --assume-role-policy-document file:///tmp/trust-relationship.json --description "Role for AWS PCA issuer"

aws iam attach-role-policy --role-name $iam_role --policy-arn "arn:aws:iam::$account_id:policy/$iam_policy"

kubectl annotate serviceaccount -n $namespace $service_account eks.amazonaws.com/role-arn="arn:aws:iam::$account_id:role/$iam_role"

kubectl rollout restart deploy $pca_issuer_deploy -n $namespace

cat << EOF | kubectl apply -f -
apiVersion: awspca.cert-manager.io/v1beta1
kind: AWSPCAClusterIssuer
metadata:
  name: aws-pca-cluster-issuer
spec:
  arn: $PCA_ARN
  region: $REGION
EOF

# rm -f /tmp/pca-issuer-policy.json /tmp/trust-relationship.json