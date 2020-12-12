from datetime import datetime

from avi.sdk.avi_api import ApiSession
from functools import partial
import collectd

CONFIG = {
    'controller_ip': None,
    'controller_port': None,
    'username': None,
    'password': None,
    'tenant': 'admin',
}

AVI_DATE_FORMAT = '%Y-%m-%d %H:%M:%S'


def configure_callback(conf):
    for node in conf.children:
        key = node.key.lower()
        value = node.values[0]

        if key in CONFIG:
            CONFIG[key] = value
        else:
            collectd.warning('avi plugin: Unknown config key: %s.' % key)
            continue

    for key, value in CONFIG.iteritems():
        assert value, "Key '%s' was not configured" % key


def read_callback():
    ipport = ':'.join([CONFIG['controller_ip'], CONFIG['controller_port']])
    try:
        api = ApiSession.get_session(controller_ip=ipport,
                                     username=CONFIG['username'],
                                     password=CONFIG['password'],
                                     tenant=CONFIG['tenant'])

        metric_config = {
          'cluster/runtime': dispatch_cluster_runtime,
          'serviceengine-inventory': partial(dispatch_inventory,
                                             plugin='avi_serviceengine'),
          'virtualservice-inventory': partial(dispatch_inventory,
                                              plugin='avi_virtualservice'),
        }

        for endpoint, dispatch_fn in metric_config.iteritems():
            resp = api.get(endpoint)
            if resp.status_code != 200:
                collectd.error('failed to collect %s stats: %s', endpoint, resp.text)
                continue
            dispatch_fn(data=resp.json())

    except Exception as e:
        collectd.warning(str(e))
        return


def dispatch_cluster_runtime(data):
    node_state = filter(lambda n: n['name'] == CONFIG['controller_ip'],
                        data.get('node_states', []))
    if len(node_state) != 1:
        collectd.warning("Somethings odd with cluster state: %s", data)
        return

    cluster_role = node_state[0]['role']
    dispatch_node_metrics(cluster_role, node_state[0])
    dispatch_cluster_metrics(cluster_role, data['cluster_state'])


def dispatch_inventory(plugin, data):
    for result in data.get('results', []):
        name = result['config']['name']
        dispatch_value(typ='health',
                       value=result['health_score']['health_score'],
                       plugin=plugin,
                       plugin_instance=name)
        dispatch_value(typ='performance',
                       value=result['health_score']['performance_score'],
                       plugin=plugin,
                       plugin_instance=name)


def dispatch_value(typ, value, plugin_instance=None, type_instance=None,
                   plugin='avi_controller'):
    val = collectd.Values(plugin=plugin)
    val.type = typ
    if type_instance:
        val.type_instance = type_instance
    if plugin_instance:
        val.plugin_instance = plugin_instance
    val.values = [value]
    val.dispatch()


def uptime(datetimestr):
    up_since = datetime.strptime(datetimestr, AVI_DATE_FORMAT)
    delta = datetime.utcnow() - up_since
    return int(delta.total_seconds())


def dispatch_cluster_metrics(plugin_instance, cluster_state):
    """
    {u'up_since': u'2016-07-24 02:16:23', u'progress': 100, u'state': u'CLUSTER_UP_HA_ACTIVE'}
    """
    cluster_uptime = uptime(cluster_state['up_since'])
    dispatch_value('uptime', type_instance='cluster', value=cluster_uptime)
    dispatch_value('progress', value=cluster_state['progress'])
    dispatch_value('cluster_state', type_instance=cluster_state['state'], value=1)


def dispatch_node_metrics(plugin_instance, node_state):
    """
    {u'up_since': u'2016-07-24 02:16:33', u'state': u'CLUSTER_ACTIVE', u'role': u'CLUSTER_FOLLOWER', u'name': u'192.168.1.13'}
    """
    node_uptime = uptime(node_state['up_since'])
    dispatch_value('uptime', type_instance='node', value=node_uptime)
    dispatch_value('node_state', type_instance=node_state['state'], value=1)
    dispatch_value('node_role', type_instance=node_state['role'], value=1)


collectd.register_config(configure_callback)
collectd.register_read(read_callback)
