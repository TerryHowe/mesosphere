job('tag-commit') {
    description('Do not edit this generated Jenkins job through WUI.')
    parameters {
        stringParam('COMMIT', null, 'Commit id or branch to tag')
        stringParam('TAG_PREFIX', 'testing', 'Tag prefix. format: <prefix>-yyyymmdd-<sequence>')
    }
    scm {
        git {
            remote {
                name('origin')
                url('git@github.webapps.rr.com:ApplicationServices/ansible.git')
                credentials('github-deploy-key-ansible')
            }
            branch("\${COMMIT}")
            extensions {
                wipeOutWorkspace()
            }
        }
    }
    wrappers {
        sshAgent('github-deploy-key-ansible')
        buildName('#${BUILD_NUMBER} ${ENV,var="GIT_TAG"}')
    }
    steps {
        shell(
            readFileFromWorkspace('roles/jenkins/admin/jobs/files/tagcommit.sh'))
        environmentVariables {
            propertiesFile('tag.properties')
        }
    }
}
