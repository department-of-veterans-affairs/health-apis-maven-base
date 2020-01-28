#!/usr/bin/env bash
set -euo pipefail
BASEDIR=$(readlink -f $(dirname $0))
RELEASE=${RELEASE:-false}
REPOSITORY=vasdvp/health-apis-maven
VERSION=${VERSION:-$(cat $BASEDIR/VERSION)}
CERTS=$BASEDIR/certs

#
# This builds a version of the base image. In the past we supported multiple version, e.g. Java 8 and Java 12.
# In the future, as we migrate to the next version of Java, we will also need to support multiple version.
#
buildMavenImage() {
  local javaVersion=$1
  # Tag format is {maven.version}-jdk-{java.major.version}
  case "$javaVersion" in
    12) local tags=(3.6-jdk-12) ;;
    *) echo "Unknown Java version: $javaVersion. Supported versions: 12" && exit 1 ;;
  esac
  docker build --pull -f $BASEDIR/Dockerfile$javaVersion $(sed "s#\([^ ]\+\)#-t $REPOSITORY:\1-$VERSION#g" <<< ${tags[@]}) $BASEDIR
  if [ $RELEASE == true ]; then
    docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
    for tag in "${tags[@]}"; do
      docker tag $REPOSITORY:$tag-$VERSION $REPOSITORY:$tag
      docker rmi $REPOSITORY:$tag-$VERSION
      docker push $REPOSITORY:$tag
    done
  fi
}


pullVaCerts() {
  if [ -d $CERTS ]; then rm -rf $CERTS; fi
  mkdir $CERTS
  local vaCertRepo=http://aia.pki.va.gov/PKI/AIA/VA/
  local vaRootCert=VA-Internal-S2-RCA1-v1.cer
  echo "Downloading $vaCertRepo/$vaRootCert"
  local status=$(curl -sw %{http_code} $vaCertRepo/$vaRootCert -o $CERTS/$vaRootCert)
  if [ "$status" != 200 ]; then echo "Failed to download VA certificates"; exit 1; fi
}

pullVaCerts
buildMavenImage 12
