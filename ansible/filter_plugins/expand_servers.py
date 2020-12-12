#
# Expand a server templated definition to individual server items. Example template:
#
#   avi-controller:
#     meta:
#       group: avi-controller
#     flavor: m3.4CPU.16GB
#     instances: 2
#     static_port: true
#     # reference existing security groups
#     security_groups:
#       - my-sec-group
#     # define volumes to be created for each instance
#     volumes:
#       data:
#         dir: /avi-data
#         size: 64
#         fstype: ext4
#     # define a server group to be created and associated to the instances
#     # scheduler_hints
#     server_group:
#       name: anti-affinity-avi-controller
#       policies:
#         - anti-affinity
#
# Expands to:
#
#   - name: avi-controller-1-nce
#     meta:
#       group: avi-controller
#     flavor: m3.4CPU.16GB
#     static_port: true
#     security_groups:
#       - my-sec-group
#     volumes:
#       data:
#         dir: /avi-data
#         size: 64
#         fstype: ext4
#     scheduler_hints:
#       group: anti-affinity-avi-controller
#   - name: avi-controller-2-nce
#     meta:
#       group: avi-controller
#     flavor: m3.4CPU.16GB
#     static_port: true
#     security_groups:
#       - my-sec-group
#     volumes:
#       data:
#         dir: /avi-data
#         size: 64
#         fstype: ext4
#     scheduler_hints:
#       group: anti-affinity-avi-controller
#
from __future__ import (absolute_import, print_function)
__metaclass__ = type


DEFAULT_NAME_FORMAT = '{name}-{instance_id}-{region}'

def expand_servers(templates, region):
    results = []
    for name, template in templates.iteritems():
        num_instances = template.pop('instances', 1)
        server_group = template.pop('server_group', {})
        for i in range(num_instances):
            instance = dict(template)
            instance['name'] = DEFAULT_NAME_FORMAT.format(name=name, instance_id=i+1, region=region)
            if server_group:
                instance.update({'scheduler_hints': {'group': server_group['name']}})
            results.append(instance)
    return results

class FilterModule(object):
     def filters(self):
         return {'expand_servers': expand_servers}
