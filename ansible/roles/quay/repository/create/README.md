# Add a repository to quay

```
---
- hosts: localhost
  roles:
    - role: quay/repository/create
      quay_name: 'preso'
```
