#!/bin/bash
#
# Provides the following controls on ansible playbook runs:
#  * prevent concurrent ansible runs against an inventory/playbook combo
#  * prevent ansible runs against an inventory/playbook
#  * prevent a quiet period after playbook

inventory=$1
playbook=$2
delay_after_secs=${3-300}

{
  ansible_run_name=${inventory}___$(echo $playbook | sed -e 's#/#__#g' -e 's#.yml$##')
  lock=/var/tmp/${ansible_run_name}.lock

  mkdir $lock 2> /dev/null
  if [ $? -ne 0 ]
  then
    echo "lock exists for $inventory $playbook, exiting. $lock"
    exit 1
  fi

  echo "running ansible for $inventory $playbook"

  #ansible-playbook -i $inventory $playbook -vv
  echo "mock ansible running, replace me with real call some day"
  sleep 60  # mock time spent doing stuff
  echo "mock ansible finished, replace me with real call some day"

  echo "delay next run for $delay_after_secs seconds"
  sleep $delay_after_secs
  echo "delay finished"

  rm -Rf $lock

} 2>&1 | logger -t $(basename $0)
