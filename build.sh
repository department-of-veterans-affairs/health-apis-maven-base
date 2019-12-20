#!/usr/bin/env bash
set -euo pipefail
#
# ------ HACK ------
#
# The certs have been removed from the maven base, this will break all new resulting builds.
# To prevent this change from percolating, we are disabling builds of the base at this time.
# Follow-up fix to come soon...
exit 0

BASEDIR=$(dirname $0)
RELEASE=${RELEASE:-false}
REPOSITORY=vasdvp/health-apis-maven
VERSION=${VERSION:-$(cat $BASEDIR/VERSION)}

do_build() {
  local java_version=$1
  case "$java_version" in
    8) local tags=(3.5-jdk-8 latest) ;;
    12) local tags=(3.6-jdk-12) ;;
    *) echo "Unknown Java version: $java_version. Supported versions are 8 and 12." && exit 1 ;;
  esac
  docker build -f $BASEDIR/Dockerfile$java_version $(sed "s#\([^ ]\+\)#-t $REPOSITORY:\1-$VERSION#g" <<< ${tags[@]}) $BASEDIR
  if [ $RELEASE == true ]; then
    docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
    for tag in "${tags[@]}"; do
      docker tag $REPOSITORY:$tag-$VERSION $REPOSITORY:$tag
      docker rmi $REPOSITORY:$tag-$VERSION
      docker push $REPOSITORY:$tag
    done
  fi
}

if [ $# == 0 ]; then
  do_build 8
  do_build 12
else
  do_build $1
fi
