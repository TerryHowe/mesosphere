#!/usr/bin/env python
#
# Vault Lookup Plugin
#
# A simple example of using the vault plugin in a role:
#    ---
#    - debug: msg="{{lookup('vault', 'ldapadmin', 'password')}}"
#
# The plugin can either be run with OS_USERNAME and OS_PASSWORD set
# and exported to valid values for LDAP.  The other option is set and
# export VAULT_TOKEN to the root token or some other token generated
# by vault.
#
# The address of vault will be generated off OS_TENANT_NAME.  It will
# convert the mesos project to the admin project if the tenant is for
# mesos.  So, for example if OS_TENANT_NAME=staging-mesos will will
# generate the url for https://vault-nce.staging-admin.cloud.twc.net:8200/
# You'll need a valid DNS or hosts entry for that domain name.
#
# Alternatively, you can set VAULT_ADDR to the url.
#
# The plugin can be run manually for testing:
#     python plugins/vault.py ldapadmin password
#
import json
import os
import requests
import sys
from urlparse import urljoin
import warnings

from ansible.errors import AnsibleError
from ansible.plugins.lookup import LookupBase
from ansible.modules.hashivault import hashivault_read


class LookupModule(LookupBase):

    def get_url(self):
        url = os.getenv('VAULT_ADDR')
        if url:
            return url.rstrip('/')
        tenant = os.getenv('OS_TENANT_NAME')
        tenant = tenant.replace("mesos", "admin")
        region = os.getenv('OS_REGION_NAME').lower()
        return ("https://vault-%s.%s.cloud.twc.net:8200" % (region, tenant))


    def get_verify(self):
        capath = os.getenv('VAULT_CAPATH')
        if capath:
            return capath
        if os.getenv('VAULT_SKIP_VERIFY'):
            return False
        return True

    def run(self, terms, variables, **kwargs):
        path = terms[0]
        key = terms[1]
        token = os.getenv('VAULT_TOKEN')
        if token:
            authtype = 'token'
        else:
            authtype = 'userpass'
        params = {
            'url': self.get_url(),
            'verify': self.get_verify(),
            'token': os.getenv('VAULT_TOKEN'),
            'authtype': authtype,
            'username': os.getenv('OS_USERNAME'),
            'password': os.getenv('OS_PASSWORD'),
            'secret': path,
            'key': key,
        }
        result = hashivault_read.hashivault_read(params)

        if 'value' not in result:
            raise AnsibleError('Error reading vault %s/%s: %s\n%s' % (path, key, result.get('msg', 'msg not set'), result.get('stack_trace', '')))
        return [str(result['value'])]


def main(argv=sys.argv[1:]):
    if len(argv) != 2:
        print("Usage: vault.py path key")
        return -1
    print LookupModule().run(argv, None)[0]
    return 0

if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
