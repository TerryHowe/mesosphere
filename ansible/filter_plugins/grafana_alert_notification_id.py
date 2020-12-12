from __future__ import (absolute_import, print_function)
from ansible import errors
import requests
from requests.auth import HTTPBasicAuth
__metaclass__ = type


def grafana_alert_notification_id(notification_name, grafana_url, grafana_username, grafana_password):
    auth = HTTPBasicAuth(grafana_username, grafana_password)
    notifications = requests.get(grafana_url + '/api/alert-notifications',
                                 auth=auth)
    for n in notifications.json():
        if n['name'] == notification_name:
            return n['id']

    raise errors.AnsibleFilterError('No notification found with name "{0}"'.format(notification_name))


class FilterModule(object):
    def filters(self):
        return {'grafana_alert_notification_id': grafana_alert_notification_id}
