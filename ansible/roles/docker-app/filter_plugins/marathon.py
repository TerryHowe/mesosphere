#
# Converts the following example data structure into a marathon json string with
# the additions needed for Avi and docker.
#
# app_spec:
#   app_name: kibana            # unique name for marathon
#   tenant_name: admin          # Avi tenant name that will be managing app
#   container_port: 5601        # port exposed within container
#   service_port: 5601          # port to expose service on mesos
#   access: internet            # one of:
#                               #    internal: service accessible only within the mesos cluster
#                               #    private: service accessible outside the cluster but only on the private subnet
#                               #    internet: service accessible from the internet
#   ssl_cert_name: my-cert      # name of cert in Avi, implies that ssl will be enabled for service
#   allowed_cidrs:              # list if cidrs that can access service when 'private' or 'internet'
#     - 0.0.0.0/0
#   marathon:                   # any valid marathon attributes
#     cpus: 0.5                 # number of cpus to allocate per instance
#     mem: 512                  # MB of memory to allocate per instance
#     instances: 1
#     container:
#       docker:                 # don't provide a portMapping, it'll be overwritten
#         image: kibana:4.2.1   # docker image hosted in trusted repo
#     env:                      # environment to pass along to container (optional)
#       foo: bar
#     args:                     # args to pass to container (optional)
#       - foo
#       - bar

from __future__ import (absolute_import, print_function)
__metaclass__ = type

import json


def to_marathon_json(app_spec, virtual_ip=None):
    marathon = dict(app_spec['marathon'])
    expose_externally = app_spec['access'] in ('private', 'internet')
    if expose_externally:
        if not app_spec.get('service_port'):
            raise ValueError('service_port is required for an private or internet accessible service')

        if not virtual_ip:
            raise ValueError('virtual_ip is required for an private or internet accessible service')

    marathon['id'] = '/{0}'.format(app_spec['app_name'])

    if marathon['container']['docker']['network'] == 'BRIDGE':
        if app_spec.get('container_port'):
            marathon['container']['docker'].update({
                'portMappings': [
                    {
                        'containerPort': app_spec['container_port'],
                        'servicePort': 0, # dynamically assigned
                        'hostPort': 0,
                    },
                ]
            })

        if app_spec.get('avi'):
            avi_proxy_label = dict(app_spec['avi'])

            if app_spec.get('service_port'):
                enable_ssl = app_spec['avi'].get('virtualservice', {}).get('ssl_profile_ref') is not None
                avi_proxy_label['virtualservice'].update({
                    'services': [
                        {
                            'port': app_spec['service_port'],
                            'enable_ssl': enable_ssl,
                        }
                    ]
                })

            avi_labels = {
                'avi_proxy': json.dumps(avi_proxy_label),
            }

            if expose_externally:
                avi_labels.update({
                    'FE-Proxy': 'yes',
                    'FE-Proxy-VIP': virtual_ip,
                })

            marathon.setdefault('labels', {}).update(avi_labels)

    return json.dumps(marathon)


class FilterModule(object):
     def filters(self):
         return {'to_marathon_json': to_marathon_json}
