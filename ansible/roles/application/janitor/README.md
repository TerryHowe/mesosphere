# Application Zookeeper Janitor

To clean up zookeeper for an application::

    ap playbooks/application-janitor.yml -e name=vault 


Optionally use::

    -e zookeeper_role_name=vault-role
    -e zookeeper_principal_name=vaultprincipal
