def inventoryEnv = "ENV"
def targetRegions = REGION == 'all' ? ['ncw', 'nce'] : [REGION]
def targetNamespaces = NAMESPACE == 'all' ? ['admin', 'mesos'] : [NAMESPACE]
def tagBuild = TAG_BUILD.toBoolean()

if (tagBuild) {
    stage "tag-build"
    build job: "tag-commit", parameters: [
        [$class: 'StringParameterValue', name: 'COMMIT', value: COMMIT],
        [$class: 'StringParameterValue', name: 'TAG_PREFIX', value: TAG_PREFIX],
    ]
}

for (int i = 0; i < targetRegions.size(); i++) {
    def region = targetRegions[i]
    for (int j = 0; j < targetNamespaces.size(); j++) {
        def namespace = targetNamespaces[j]
        def inv = "${inventoryEnv}-${namespace}-${region}"
        stage "${inv}"

        build job: "${inv}-playbook", parameters: [
            [$class: 'StringParameterValue', name: 'ANSIBLE_PLAYBOOK', value: ANSIBLE_PLAYBOOK],
            [$class: 'StringParameterValue', name: 'COMMIT', value: COMMIT],
        ]
    }
}
