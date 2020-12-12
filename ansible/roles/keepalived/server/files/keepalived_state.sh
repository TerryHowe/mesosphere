#!/bin/sh

cat <<EOF > /var/run/keepalived.$1.$2.state
type=$1
name=$2
state=$3
EOF
