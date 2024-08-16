DEST_REG=gcr.io/xcp-istio
SOURCE_REG=docker.io/imnizam
IMG=“xcpd:6a873619d5ddd38c93186fc9099684af5fbdb5c5”
skopeo copy --all docker://${SOURCE_REG}/${IMG} docker://${DEST_REG}/${IMG}
IMG=“spm-user:3f876e35d17206ab5e3497c9c6e4639b78cdf08b”
skopeo copy --all docker://${SOURCE_REG}/${IMG} docker://${DEST_REG}/${IMG}
IMG=“proxyv2:1.21.4-9adece3cec-distroless”
skopeo copy --all docker://${SOURCE_REG}/${IMG} docker://${DEST_REG}/${IMG}
IMG=“otelcol:0.105.0"
skopeo copy --all docker://${SOURCE_REG}/${IMG} docker://${DEST_REG}/${IMG}
IMG=“tsboperator-server:26e7773a9e6c872cb418a38a209740f2be892456”
skopeo copy --all docker://${SOURCE_REG}/${IMG} docker://${DEST_REG}/${IMG}
IMG=“xcp-operator:6a873619d5ddd38c93186fc9099684af5fbdb5c5"
skopeo copy --all docker://${SOURCE_REG}/${IMG} docker://${DEST_REG}/${IMG}


##########
images
#########
docker.io/imnizam/xcpd:6a873619d5ddd38c93186fc9099684af5fbdb5c5
docker.io/imnizam/spm-user:3f876e35d17206ab5e3497c9c6e4639b78cdf08b
docker.io/imnizam/proxyv2:1.21.4-9adece3cec-distroless
docker.io/imnizam/otelcol:0.105.0
docker.io/imnizam/tsboperator-server:26e7773a9e6c872cb418a38a209740f2be892456
docker.io/imnizam/xcp-operator:6a873619d5ddd38c93186fc9099684af5fbdb5c5