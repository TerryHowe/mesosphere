from ansible.plugins.action import ActionBase


class ActionModule(ActionBase):

    def run(self, tmp=None, task_vars=None):

        if task_vars is None:
            task_vars = dict()
        result = super(ActionModule, self).run(tmp, task_vars)
        args = self._task.args.copy()
        if 'authtype' not in args:
            args['authtype'] = 'userpass'
        if 'url' not in args:
            args['url'] = self._templar.template('https://vault-{{region}}.{{admin_domain}}:8200')
        if 'username' not in args:
            args['username'] = self._templar.template('{{os_username}}')
        if 'password' not in args:
            args['password'] = self._templar.template('{{os_password}}')
        result.update(self._execute_module(module_args=args, task_vars=task_vars))
        return result
