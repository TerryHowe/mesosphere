#!/bin/bash
# Parse arguments
while [[ $# -gt 1 ]]
do
key="$1"
case $key in
    -m|--master)
    MASTER="$2"
    shift
    ;;
    -t|--tasks)
    TASKS="$2"
    shift
    ;;
    *)
    ;;
esac
shift
done
if [ -z "${MASTER}" ] || [ -z "${TASKS}" ]; then
    echo 'Usage: ./get_task_logs.sh -m $master_ip -t $num_of_tasks' && exit 1
fi
TIMESTAMP=$(date "+%Y%m%d%H%M%S")
TMPDIR="/tmp/${TIMESTAMP}"
STATE=$(curl -sl "http://${MASTER}:5050/state.json")
AGENTS=$(echo "${STATE}" | jq -r '.slaves[].hostname')
COUNT=0
# Get all mesos-agents from master state.json
for AGENT in $AGENTS; do
    AGENT_STATE=$(curl -sl "http://${AGENT}:5051/state.json")
    # Get the paths to all framework task logs
    FRAMEWORK_PATHS=$(echo "${AGENT_STATE}" | jq -r '.frameworks[].executors[].directory')
    for FRAMEWORK_PATH in $FRAMEWORK_PATHS; do
        if (( "$COUNT" < "${TASKS}" )); then
            for LOG in stdout stderr; do
                mkdir -p "${TMPDIR}${FRAMEWORK_PATH}"
                curl -sf "http://${AGENT}:5051/files/download.json?path=${FRAMEWORK_PATH}/${LOG}" > "${TMPDIR}${FRAMEWORK_PATH}/${LOG}"
            done
            ((COUNT++))
        fi
    done
done
tar -czf "/tmp/tasklog-${TIMESTAMP}.tar.gz" -C "${TMPDIR}" . && rm -rf "${TMPDIR}" && echo "Created /tmp/tasklog-${TIMESTAMP}.tar.gz" || echo "Could not create .tar.gz.  Check ${TMPDIR}."
