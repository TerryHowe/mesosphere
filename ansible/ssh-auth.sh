#!/bin/bash

environment=$1

temp_file=$(mktemp /tmp/.${environment}-sshkey)

private_key=`ansible-vault decrypt --output=${temp_file} roles/provision-openstack/files/privkeys/cloud-user-${environment}.pem`

`ssh-add $temp_file`

rm ${temp_file}

echo "SSH Authenticated for ${environment}"

exit 0
