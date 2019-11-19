#!/usr/bin/env bash
set -euo pipefail

RELEASE=${RELEASE:-false}
REPOSITORY=vasdvp/health-apis-maven

do_build() {
  version=$1
  case "$version" in
    8) tags=(piv-87-3.5-jdk-8 piv-87-latest) ;;
    12) tags=(piv-87-3.6-jdk-12) ;;
    *) echo "Unknown version: $version. Supported versions are 8 and 12." && exit 1 ;;
  esac
  docker build -f Dockerfile$version $(sed "s#\([^ ]\+\)#-t $REPOSITORY:\1#g" <<< ${tags[@]}) .
  if [ $RELEASE == true ]; then
    docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
    for tag in "${tags[@]}"; do
      echo "docker push $REPOSITORY:$tag"
    done
  fi
}

if [ $# == 0 ]; then
  do_build 8
  do_build 12
else
  do_build $1
fi
