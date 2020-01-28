#!/usr/bin/env bash
set -euo pipefail
BASEDIR=$(dirname $0)
RELEASE=${RELEASE:-false}
REPOSITORY=vasdvp/health-apis-maven
VERSION=${VERSION:-$(cat $BASEDIR/VERSION)}

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
  docker build -f $BASEDIR/Dockerfile$javaVersion $(sed "s#\([^ ]\+\)#-t $REPOSITORY:\1-$VERSION#g" <<< ${tags[@]}) $BASEDIR
  if [ $RELEASE == true ]; then
    docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
    for tag in "${tags[@]}"; do
      docker tag $REPOSITORY:$tag-$VERSION $REPOSITORY:$tag
      docker rmi $REPOSITORY:$tag-$VERSION
      docker push $REPOSITORY:$tag
    done
  fi
}

buildMavenImage 12
