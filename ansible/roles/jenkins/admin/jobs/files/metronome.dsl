job('metronome') {
    description('Do not edit this generated Jenkins job through WUI.')
    label('dcos-slave')
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
    triggers {
      scm('H 0 */1 * *')
    }
    steps {
        shell(
            readFileFromWorkspace('roles/jenkins/admin/jobs/files/shebang.sh') +
            readFileFromWorkspace('roles/jenkins/admin/jobs/files/metronomeenv.sh') +
            readFileFromWorkspace('roles/jenkins/admin/jobs/files/metronome.sh'))
    }
}
