def managedInventories = MANAGED_INVENTORIES.split(',').toList()

managedInventories.each { inventory ->
    def keyenv = inventory.split('-')[0]
    job("${inventory}-playbook") {
        description('Do not edit this generated Jenkins job through WUI.')
        label('dcos-slave')
        parameters {
            stringParam('ANSIBLE_PLAYBOOK')
            stringParam('COMMIT')
        }
        scm {
            git {
                remote {
                    name('origin')
                    url('https://github.webapps.rr.com/ApplicationServices/ansible.git')
                }
                branch('\${COMMIT}')
                extensions {
                    wipeOutWorkspace()
                }
                configure { node ->
                    node / 'extensions' << 'hudson.plugins.git.extensions.impl.ChangelogToBranch' {
                        options {
                            compareRemote 'origin'
                            compareTarget 'master'
                        }
                    }
                }
            }
        }
        wrappers {
            credentialsBinding {
                usernamePassword('OS_USERNAME', 'OS_PASSWORD', 'openstack')
            }
            sshAgent("ansible-${keyenv}")
            buildName('#${BUILD_NUMBER} ${ENV,var="GIT_REV"}')
        }
        steps {
            shell(
                readFileFromWorkspace('roles/jenkins/admin/jobs/files/shebang.sh') +
                readFileFromWorkspace('roles/jenkins/admin/jobs/files/setosenv.sh').replace('<ANSIBLE_INVENTORY>', inventory) +
                readFileFromWorkspace('roles/jenkins/admin/jobs/files/playbook.sh'))
            environmentVariables {
                propertiesFile('tag.properties')
            }
            updateJiraExt {
                issueStrategy {
                    firstWordOfCommit()
                }
                jiraOperations {
                    commentTemplate = """{panel:title=inventory: ${inventory}}
\${ANSIBLE_PLAYBOOK}

[\${BUILD_TAG}|\${BUILD_URL}] ??\${GIT_REV}??
{panel}"""
                    addComment(commentTemplate, false)
                    addLabel(inventory)
                }
            }
        }
    }
}
