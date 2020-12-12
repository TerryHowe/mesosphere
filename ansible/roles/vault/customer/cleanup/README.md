# Vault Customer Teardown
Remove a user from mesos vault with a playbook similar to:
```
---
- hosts: localhost
  vars:
    customer:
      name: "Terry Test Customer"
      shortname: "terry"
      email: "terry.howe@bobby.com"
      password: "{{ lookup('vault', 'customer_terry', 'password') }}"
  roles:
    - role: vault/customer/cleanup
```
Only the shortname is used.
