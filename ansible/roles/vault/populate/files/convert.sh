#!/bin/bash -x
PEMFILE="${1}"
PASSWORD="${2}"
grep -v '^subject=' $PEMFILE | grep -v '^issuer=' >out
LINE=$(awk '/BEGIN RSA PRIVATE KEY/{ print NR; exit }' out)
LINE=$(expr $LINE - 1)
LINE=$(expr $LINE - 1)
DIR=$(basename $PEMFILE| sed -e 's/[^.]*\.//' -e 's/\..*//' -e 's/-mesos/-admin/')
PUBLIC=${DIR}/$(basename $PEMFILE | sed -e 's/cloud.bobby.net.pem/public/')
PRIVATE=${DIR}/$(basename $PEMFILE | sed -e 's/cloud.bobby.net.pem/private/')
head -$LINE out >$PUBLIC
rm -f out
openssl rsa -passin "pass:${PASSWORD}" -in ${PEMFILE} -out ${PRIVATE}
ansible-vault encrypt ${PRIVATE}
