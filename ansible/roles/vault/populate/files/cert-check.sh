#!/bin/bash

expected=$(mktemp cert-check-XXXX)

function validate {
  echo $1 >> $expected
  certfile=$(find . -name $1)
  cnt=$(echo -n $certfile | wc -l | sed 's/ //g')
  if [[ ! -f $certfile ]]
  then
    echo "Missing cert: $1"
    return
  fi

  openssl x509 -in $certfile -text | egrep -q "Issuer:.*CN=(Time Warner Cable|Symantec)" || echo "WARNING: Bogus issuer found for $certfile"

  subject=$(openssl x509 -in $certfile  -text -noout | grep Subject: | sed -e 's/^[[:space:]]*//')
  cn_host=$(echo $subject | sed -e 's/^.*CN=\(.*\).cloud.twc.net/\1/')
  file_host=$(echo $certfile | sed -e 's/^.*\/\([^\/]*\)\.public/\1/')

  if [ "$file_host" != "$cn_host" ]; then
    echo "Bad Hostname: $certfile (actual: $cn_host, expected: $file_host)"
  fi
  
}

for cert in {avi,grafana,graphite,jenkins,kibana,mesos,monitor,registry,vault}-{nce,ncw}.{dev,staging,prod}-admin.public
do
  validate $cert
done

for cert in {avi,mesos,vault}-{nce,ncw}.{dev,staging,prod}-mesos.public
do
  validate $cert
done

echo "Unneeded certs:"
for cert in $(find . -name \*.public | awk -F'/' '{print $3}')
do
  grep -q $cert $expected && continue
  public_filename=$(ls */${cert})
  private_filename=$(ls */${cert} | sed -e 's/public/private/')
  echo "$public_filename"
  echo "$private_filename"
done

rm $expected
