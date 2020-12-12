# Create tags in the format: <prefix>-yyyymmdd-<sequence>
git config user.name jenkins
git config user.email jenkins@${NODE_NAME}
tag_base="${TAG_PREFIX}-`date '+%Y%m%d'`"
tag_seq=`git tag | grep -o "${tag_base}.*[0-9]$" | sort -rn | head -1 | awk -F'-' '{ printf("%02d", $NF + 1) } END { if (NR == 0) print "01" }'`
tag="${tag_base}-${tag_seq}"
echo "GIT_TAG=$tag" > tag.properties
git tag -a $tag -F- <<EOF
BUILD_TAG: ${BUILD_TAG}
JENKINS_URL: ${JENKINS_URL}
JOB_NAME: ${JOB_NAME}
EOF
git push origin --tags
