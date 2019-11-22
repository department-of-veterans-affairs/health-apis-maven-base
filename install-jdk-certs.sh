#!/usr/bin/env bash

# Java 8 cacerts in a different location than it is in 12
# we should default to 8 but check for both
JAVA_CACERTS="$JAVA_HOME/jre/lib/security/cacerts"
[ -f "$JAVA_HOME/lib/security/cacerts" ] && JAVA_CACERTS="$JAVA_HOME/lib/security/cacerts"
keytool -import -trustcacerts -alias freedomstream -file /tmp/2a0f55789cb15a14.crt -keystore $JAVA_CACERTS <<EOF
changeit
yes
EOF
