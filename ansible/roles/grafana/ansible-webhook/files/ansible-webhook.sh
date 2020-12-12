#!/bin/bash
#
# Parse an HTTP request for a url with the following pattern:
# POST /<inventory>/path/to/playbook.yml

read -a reqline
inventory=$( echo ${reqline[1]} | cut -d/ -f2)
playbook="/$( echo ${reqline[1]} | cut -d/ -f3-)"

(
  echo "Inventory[$inventory] Playbook[$playbook]"
  at now <<EOF
/usr/local/bin/ansible-playbook-safe.sh $inventory $playbook
EOF
) 2>&1 | logger -t $(basename $0)

echo "HTTP/1.0 200 OK"
echo "Content-Type: text/plain"
echo "Connection: close"
echo "Content-Length: 3"
echo
echo "OK"
