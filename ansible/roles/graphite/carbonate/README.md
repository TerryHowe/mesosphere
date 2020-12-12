Add a new carbon-cache node
---------------------------

### 1. Add new carbon-cache node(s)

   ```
   [admin] playbooks/provision-openstack.yml -vv --tags server
   ```

##### User-facing impacts to monitoring services
 * none

### 2. Configure new carbon-cache node(s)

 ```
 [admin] playbooks/graphite/carbon/carbon-cache.yml
 ```

##### User-facing impacts to monitoring services
* none

### 3. Configure carbonate with old and new cluster composition

```
[admin] playbooks/graphite/carbonate/install.yml -vv -e new_carbon_cache_nodes=carbon-cache-3-{{region}} -e old_replication_factor=1
```

##### User-facing impacts to monitoring services
* none

### 4. Update carbon-relay to use updated node set
```
[admin] playbooks/graphite/carbon-relay.yml -vv
```

##### User-facing impacts to monitoring services
* grafana and graphite-web will not reflect updates to metrics that are
 now being published to a different node

##### Internal impacts

* carbon-relay will now write will metrics to their new home in the cluster
 due to the changed composition of the cluster and the use of consistent
 hashing
* moira's metric stream will not be affected

### 5. Update graphite web to use updated node set
```
[admin] playbooks/graphite/graphite-web.yml -vv
```
##### User-facing impacts to monitoring services
 * grafana and graphite-web will not contain history for metrics that are
   now being published to a different node

### 6. Rebalance carbon-cache

```
[admin] playbooks/graphite/carbonate/rebalance.yml --tags schedule-job -vv -e new_carbon_cache_nodes=carbon-cache-3-{{region}} -e old_replication_factor=1
```

Starts a background job on each carbon-cache node that will pull metrics
from their old home in the cluster. This data will be merged with the new
data that is arriving.

##### User-facing impacts to monitoring services
* history will slowly be backfilled until sync from all nodes in complete
* potential for service slowdowns as disk IO and network will be busy
   handling bits

##### Debugging
* background job is managed by atd, run the `atq` command to see the job
 before its fired off
* rebalance is handled by [carbonate](https://github.com/graphite-project/carbonate)
  which includes `carbon-sync`, `carbon-list` among other helpful scripts
* carbonate configuration: `/opt/graphite/conf/carbonate.conf`
* the rebalance script outputs various files including a log file under
 `/var/run/carbonate/`
* explanation of script outputs:
  * rebalance.*other-carbon-cache-ip*.carbon-list.*jobid* - list of all the
    metrics that the other carbon-cache node holds. This identifies where
    data fell in the old hashring.
  * rebalance.*other-carbon-cache-ip*.carbon-sieve.*jobid* list of all the
    metrics that the other carbon-cache node holds that belong to this
    node.
  * rebalance.carbon-sieve.spurious.*jobid* - list of metrics that this
    node holds but are no longer published to this node due to hashring changes.
    *Note*: the metrics are not deleted currently
  * rebalance.*jobid*.log - script output and timings from carbon-sync
    script
