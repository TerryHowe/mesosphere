# Add a DNS record

```
- hosts: worker
  roles:
    - role: dns/record
      domain_name: registry-{{ region }}
```
