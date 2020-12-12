# Build a repository in quay

```
---
- hosts: localhost
  roles:
    - role: quay/repository/build
      quay_name: 'preso'
```
