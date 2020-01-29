#!/usr/bin/env bash
set -euo pipefail

trustMe() {
  local crt="$1"
  local nickname=$(basename $crt)
  nickname=${nickname%.*}
  echo "Trusting $nickname"
  # Add cert to system
  cp $crt /etc/pki/ca-trust/source/anchors/
  # Add cert to JDK
  keytool -import -cacerts -trustcacerts -alias $nickname -file $crt <<EOF
changeit
yes
EOF
}

trustCerts() {
  local certsDir="$1"
  for crt in $certsDir/*.cer
  do
    trustMe $crt
  done
  update-ca-trust extract
  #
  # Jenkins runs this container as 'jenkins' or other users. These users sometimes need to add
  # additional certs to the JDK. We will open access to cacerts to allow easy modification.
  #
  chmod 666 $(find $JAVA_HOME -name cacerts)
}


#
# Trust certs copied into the container during build time
#
trustCerts /tmp/certs
