# Delete a repository from quay

```
---
- hosts: localhost
  roles:
    - role: quay/repository/delete
      quay_name: 'preso'
```
