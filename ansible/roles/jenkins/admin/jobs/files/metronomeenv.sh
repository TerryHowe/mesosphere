# setup ansible to run against an inventory
source ~/.venv/bin/activate
region=$(echo ${OS_REGION_NAME} | tr 'A-Z' 'a-z')
# jenkins runs shell with -x, temporarily disable so we dont show password
set +x
echo "${OS_PASSWORD}" > ~/ansiblevault
if [ -f ansible-jenkins.cfg ]
then
  export ANSIBLE_CONFIG="$(pwd)/ansible-jenkins.cfg"
fi
dcos config set core.dcos_url "https://admin:${OS_PASSWORD}@mesos-${region}.${OS_TENANT_NAME}.cloud.bobby.net" > /dev/null 2>&1
dcos auth login > /dev/null 2>&1
if [ $? -ne 0 ]
then
  echo "Failed to login to DCOS"
  exit 1
fi
set -x
