def inventories = MANAGED_INVENTORIES.split(',').toList()
def envs = inventories.collect { it.split('-')[0] }.unique()
def regions = inventories.collect { it.split('-')[2] }.unique()


envs.each { inventoryEnv ->
    def tagPrefix = inventoryEnv.startsWith('prod') ? 'release' : 'testing'
    pipelineJob("${inventoryEnv}-pipeline") {
        description('Example pipeline from dsl')
        def regionChoices = regions.size() > 1 ? regions + ['all'] : regions
        parameters {
            choiceParam('REGION', regionChoices, 'Region to run playbook against.')
            choiceParam('NAMESPACE', ['admin', 'mesos', 'all'], 'Namespace to run playbook against.')
            stringParam('COMMIT', null, 'Commit id or branch to use.')
            stringParam('ANSIBLE_PLAYBOOK', null, 'Ansible playbook to run, can provide any additional args here as well.')
            booleanParam('TAG_BUILD', false, 'Tag the commit before running playbook')
            stringParam('TAG_PREFIX', tagPrefix, 'Prefix to use for the tag, only applicable if tagging.')
        }
        definition {
            cps {
                script(readFileFromWorkspace('roles/jenkins/admin/jobs/files/envpipeline.groovy').replace('ENV', inventoryEnv))
            }
        }
    }
}
