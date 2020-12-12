
# admin token
dcos_acs_token="eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE0Nzk2NTcxNDYsInVpZCI6ImFkbWluIn0.eNq5w4fms1jKmWScSuvBICt7N_BKpiLM1iSsZstrGm7wgiLsHlhDOys3eeKXVoNE7L7clWBeuvIAXLjam3-6svgpwbIUkOYisX4h388wbwI0xl62ek9hxnZzJPg7NEWkAcVSe_D-HwKHR6By5zEVu5MrzGIj7BmQSA7IDqv5A70vnNrfO8KzZGZak0-00kp945ObasFSd0B72d2M3SQyVFKdfyZbz9a0TfeomMtImvkk-yQqbVz7cZbbeH1Oa0qddqx_RsYdi0sYW3OqpQirTTGqcHVyayqQ1Yqj1_X6UG1iBFo_9tkDFcaVX14jWC96tnvqOw59DzIKaHYailXP8g"

#path='service/marathon/v2/leader'
#path='secrets/v1/secret/default/terry/password'
#path='acs/api/v1/acls'
#path='acs/api/v1/groups'
#path='/acs/api/v1/acls/dcos:secrets:default:%252Fterry%252Fpassword/groups/terry-admins'
#path='/acs/api/v1/acls/dcos:secrets:default:%252Fterry/groups/terry-admins/full'

#for path
#in "/acs/api/v1/acls/dcos:secrets:default:%252Fterry%252Ftreasure" "/acs/api/v1/acls/dcos:secrets:default:%252Fterry%252Fpassword" "/acs/api/v1/acls/dcos:secrets:list:default:%252Fterry" "/acs/api/v1/acls/dcos:secrets:default:terry%252Fpassword" "/acs/api/v1/acls/dcos:secrets:default:%252Fterry" "/acs/api/v1/acls/dcos:secrets:default:terry"
#do
#  -X 'DELETE' \
#done
dcos_url="https://mesos-nce.dev-mesos.cloud.bobby.net"
# terry token
#dcos_acs_token="eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE0Nzk3NjU5MDIsInVpZCI6InRlcnJ5LWFkbWluIn0.tS6DtyjrYUAos_tAndgcWRRZM6Q38Xtj_syOUgu5Vm4_sAkk9ua9JQWty8Of3lkZ2uVwOLdGpo5-0MaQkAZOyz9YJSTrFjbs7F3Zwo3fz_FsJR5Nwk00Z7d6t6I_1QFKLqQU5EqgI-6NCR1a_rPAW0Y_pD-IcXlSNX-c4DHfiYFts4IpYKkCK0_Dr4m8-wm6vLvGGViXCYfERs-cVE7jNZTO_ndKUqBz3jOlAeUQK9g9x0qmFtVs6w4iWlMjADFYWKY2K9JO4p9ivj8XoWooGb6bGim4vkOVR2wivr5QFwqws49bipVKtO01QN-MXcyqmgaKO6obzh8NRE1tTbJo1A"

#path='/service/marathon-terry/v2/apps'
#path='/service/jenkins-terry/login'
#JSON='{  "id":"/terry/terry-wtf", "cpus": 0.25, "mem": 128.0, "instances": 1, "cmd":"env && sleep 100", "env":{ "TERRY_PASSWORD":{ "secret":"secret0" } }, "secrets":{ "secret0":{ "source":"terry/password" } } }'
#  -d "$JSON" \
#  -H "Content-Type: application/json" \


path='/service/cassandra/v1/plan'
curl -v \
  -X 'GET' \
  -H "Authorization: token=${dcos_acs_token}" \
  ${dcos_url}/${path}
