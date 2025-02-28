SCRIPTPATH=$(dirname "$0")
kubectl apply -f ${SCRIPTPATH}/es.yaml

sleep 60 ;

kubectl apply -f ${SCRIPTPATH}/es-cr.yaml

# made es ca and credentials part of values.yaml
# kubectl -n tsb delete secret es-certs elastic-credentials
# sleep 10 ;

# kubectl -n tsb apply -f ${SCRIPTPATH}/es-secrets.yaml
#and change controplane obj for direct access
# kubectl -n istio-system apply -f es-secrets.yaml

# update mp configuration with 
#   telemetryStore:
#     elastic:
#       host: tsb-es-http.elastic.svc  # make sure its up .svc
#       port: 9200
#       protocol: http
#       version: 7

# If multi cluster is there, apply es-lb config
# k apply -f es-lb-svc.yaml
# Now on each controlplane 
# kubectl -n istio-system delete secret es-certs elastic-credentials
# kubectl -n istio-system apply -f es-secrets.yaml
