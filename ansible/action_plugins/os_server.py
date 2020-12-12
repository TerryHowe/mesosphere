#
# Allows sheduler_hints group to be specified by name rather than id
#
from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

from ansible.plugins.action import ActionBase

try:
  import shade
  HAS_SHADE = True
except ImportError:
  HAS_SHADE = False

try:
    from __main__ import display
except ImportError:
    from ansible.utils.display import Display
    display = Display()

class ActionModule(ActionBase):

    _cloud = shade.openstack_cloud()
    _cache = {}

    def run(self, tmp=None, task_vars=None):
        if task_vars is None:
            task_vars = dict()

        result = super(ActionModule, self).run(tmp, task_vars)
        args = self._task.args.copy()

        if not HAS_SHADE:
            result['failed'] = True
            result['msg'] = 'Python shade library required'
            return result

        group = args.get('scheduler_hints', {}).get('group')
        if group:
            try:
                group_id = self._cache[group]
            except KeyError:
                server_group = self._cloud.get_server_group(group)
                if not server_group:
                    result['failed'] = True
                    result['msg'] = 'Failed to find os_server_group "{0}"'.format(group)
                    return result
                self._cache[group] = self._cloud.get_server_group(group)['id']
                group_id = self._cache[group]
            args['scheduler_hints']['group'] = group_id
        result.update(self._execute_module(module_args=args, task_vars=task_vars))
        return result
