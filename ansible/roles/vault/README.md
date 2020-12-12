# Vault Roles
The vault roles cover all aspects of vault for PaaS including use of
vault for internal purposes and for external customer purposes.  The
internal vault is created with the vault/admin role and populated with
the vault/populate role.  The external customer facing vault is created
with the vault/mesos role.

Internal vault runs in the admin environment for both admin and mesos
environments.  The lookup plugin will make an attempt to access vault
in the admin project even if you are configured to run in mesos.

## Test Vault Connectivity

You can use the playbook/vault/test.yml playbook to test your connectivity to
vault with your environment.

```bash
$ ansible-playbook -i staging-admin-nce playbooks/vault/test.yml

PLAY ***************************************************************************

TASK [setup] *******************************************************************
ok: [localhost]

TASK [debug] *******************************************************************
ok: [localhost] => {
    "msg": "Test successful"
}

PLAY RECAP *********************************************************************
localhost                  : ok=2    changed=0    unreachable=0    failed=0   
```

## Read a Secret from Vault
There is a lookup plug that should be used to read secrets from
vault.  Pass the plugin the secret and the secret key you are looking
for.  Each secret can have multiple key vaule pairs.  In this example
we are getting the git trigger id and secret.

```
git_trigger_id: "{{lookup('vault', 'git_trigger', 'id')}}"
git_trigger_secret: "{{lookup('vault', 'git_trigger', 'secret')}}"
```

## Write a Secret to Vault
There are two ways you may want to write a secret to vault.  If
the secret is an external secret, it should go into the vault
populate role.  If it is a generated secret that is part of the
environment, it should be writen in a playbook.

### Using Vault Populate
Vault populate uses two methods to store secrets: vars and files.
The vars secrets work well for small secrets and if a secret has
multiple key value pairs.  File secrets are great for things like
SSL/TLS private keys.

#### Vault Populate Vars Secrets
The vars secrets are stored in a common or environment specific
vars file.  To add/change a vars secret, use ansible-vault to
edit the file that needs modification:

```
ansible-vault edit roles/vault/populate/vars/dev-admin.yml 
```

Environment secrets are stored in the project_secrets dictionary.
For example:
```
---
project_secrets:
    git_client:
        id: "gordie"
        secret: "hattrick"
    ...
```
Add the secret, encrypt the file and check it in.

The common.yml uses the common_secrets dictionary.

```
---
common_secrets:
    ldap:
        password: 'redwings'
    ...
```

#### Vault Populate File Secrets
Secrets in the vault/populate files directory are stored by environment.
SSL/TLS certificates and keys are both stored in vault so that they can
remain in sync.  Certificates are stored in '.public' files and keys are
stored in '.private' files.  The certificates do not need to be encrypted.


### Writing Playbook Generated Secrets
If you playbook creates a secret that is needed for other playbooks, it
may be convenient to write that secret to vault.  If your secret was
named jenkins and the key was apitoken:

```
- name: add token to vault
  become: no
  local_action: hashivault_write
  args:
      secret: jenkins
      update: True
      data:
          apitoken: "{{apitoken.stdout}}"
```
The update option in this example will add the key value pair without
deleting other key value pairs for that secret.
