# Vault Customer Setup
A mesos vault customer needs a policy and a user entry in the userpass
auth method.  This role creates both the policy and the user.  Here is
a sample playbook to create a user:
```
---
- hosts: mesos-agent
  vars:
    customer:
      name: "Terry Test Customer"
      shortname: "terry"
      email: "terry.howe@bobby.com"
      password: "{{ lookup('vault', 'customer/terry', 'password') }}"
  roles:
    - role: vault/customer/setup
```

The customer will have access to secrets within a namespace created
from their shortname.  For example, if their shortname is "terry", the
CLI commands to write and read secrets would look like:
```
$ vault write secret/terry/foo bar=b
Success! Data written to: secret/terry/foo
$ vault read secret/terry/foo
Key             Value
lease_duration  2592000
bar             b
```
Reading or writing outside of secret/terry/ will result in a 403
forbidden.
