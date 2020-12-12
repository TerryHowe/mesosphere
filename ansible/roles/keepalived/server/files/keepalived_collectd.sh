HOSTNAME="${COLLECTD_HOSTNAME:-localhost}"
INTERVAL="${COLLECTD_INTERVAL:-60}"

while sleep "$INTERVAL"
do
  for state_file in /var/run/keepalived.*.state
  do
    source $state_file
    for a_state in MASTER BACKUP FAULT
    do
        metric="$HOSTNAME/keepalived-${type}-${name}/gauge-${a_state}"
        value=$([ $state == $a_state ] && echo 1 || echo 0)
        echo "PUTVAL \"${metric}\" interval=$INTERVAL N:$value"
    done
  done
done
