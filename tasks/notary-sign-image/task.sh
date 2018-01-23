#!/bin/bash
set -e

source /opt/resource/common.sh



function fn_decode {
  echo $1 | base64 -d
}


mkdir -p /etc/docker/certs.d/$HARBOR_URL
fn_decode $HARBOR_CA_CERT > "/etc/docker/certs.d/$HARBOR_URL/ca.crt"
echo "{\"insecure-registries\" : [\"$HARBOR_URL\"]}" > /etc/docker/daemon.json
mkdir -p "$HOME/.docker/tls/$HARBOR_URL:4443"
fn_decode $HARBOR_CA_CERT > "$HOME/.docker/tls/$HARBOR_URL:4443/ca.crt"

start_docker

docker login $HARBOR_URL -u $HARBOR_USERNAME -p $HARBOR_PASSWORD
docker pull $HARBOR_IMAGE
docker images

export DOCKER_CONTENT_TRUST=1
export DOCKER_CONTENT_TRUST_SERVER="https://$HARBOR_URL:4443"
export DOCKER_CONTENT_TRUST_ROOT_PASSPHRASE="$NOTARY_ROOT_PASS"
export DOCKER_CONTENT_TRUST_REPOSITORY_PASSPHRASE="$NOTARY_REPO_PASS"


docker push $HARBOR_IMAGE 2>/dev/null