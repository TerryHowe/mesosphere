source ~/.venv/bin/activate

git_rev=$(git describe --exact || git rev-parse --short HEAD)
echo "GIT_REV=$git_rev" > tag.properties
ansible-galaxy install -r install-roles.yml
ansible-playbook -i ${ANSIBLE_INVENTORY} -e deploy_tag_ref=${git_rev} -e deploy_job_ref=${BUILD_TAG} ${ANSIBLE_PLAYBOOK_OPTS} ${ANSIBLE_PLAYBOOK}
