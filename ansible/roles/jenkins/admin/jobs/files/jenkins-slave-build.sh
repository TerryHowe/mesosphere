echo "${OS_PASSWORD}" > ~/ansiblevault
if [ -f ansible-jenkins.cfg ]
then
  export ANSIBLE_CONFIG="$(pwd)/ansible-jenkins.cfg"
fi
region=$(echo "${OS_REGION_NAME}" | tr '[:upper:]' '[:lower:]')
ANSIBLE_INVENTORY="${OS_TENANT_NAME}-${region}"

test ! -d .venv && virtualenv .venv
source .venv/bin/activate
pip install pip
pip install -r requirements.txt
pip install setuptools --upgrade
ansible-playbook -i "${ANSIBLE_INVENTORY}" playbooks/jenkins/slave.yml
