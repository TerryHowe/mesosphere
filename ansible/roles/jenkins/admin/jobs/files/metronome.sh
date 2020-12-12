echo "${OS_PASSWORD}" > ~/ansiblevault
if [ -f ansible-jenkins.cfg ]
then
  export ANSIBLE_CONFIG="$(pwd)/ansible-jenkins.cfg"
fi
region=$(echo "${OS_REGION_NAME}" | tr '[:upper:]' '[:lower:]')
ANSIBLE_INVENTORY="${OS_TENANT_NAME}-${region}"

ansible-playbook -i ${ANSIBLE_INVENTORY} playbooks/metronome/monitoring.yml
