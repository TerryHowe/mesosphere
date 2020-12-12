job('jenkins-slave-build') {
    description('Do not edit this generated Jenkins job through WUI.')
    parameters {
        stringParam('COMMIT', 'master', 'Commit id or branch')
    }   
    wrappers {
        credentialsBinding {
            usernamePassword('OS_USERNAME', 'OS_PASSWORD', 'openstack')
        }
        sshAgent('ansible')
    }
    scm {
        git {
            remote {
                name('ansible')
                url('https://github.webapps.rr.com/ApplicationServices/ansible.git')
            }
            branch("\${COMMIT}")
            extensions {
                wipeOutWorkspace()
            }
        }
    }
    steps {
        shell(
            readFileFromWorkspace('roles/jenkins/admin/jobs/files/shebang.sh') +
            readFileFromWorkspace('roles/jenkins/admin/jobs/files/jenkins-slave-build.sh'))
    }
}
