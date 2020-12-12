# ansible
Testing out ansible for build and config management of mesosphere.

## Development Setup

  1. Ensure you have a personal OpenStack project, open an OPSC ticket for
     'Project Creation' if needed.

  1. Download the OpenStack RC file for your account

  1. Source the OpenStack RC file

  1. Authenticate your ssh agent.

     You will need to add the appropriate ssh key to your local ssh-agent before running ansible.

     To do this, run: `./ssh-auth.sh <env>`, e.g. `./ssh-auth.sh dev` for access to dev envs.

     This authentication will remain active until you reboot or manually delete the key.

  1. Configure ansible

     Configuration of ansible resides in ansible.cfg in the root of the repository.
     Some paths are pre-set and need files placed in specific locations.

     Create a password file containing the vault password in text on a single line at:
     ```
     ${HOME}/.ansiblevault
     ```
  
  1. Download and copy the DCOS CLI binary to your local bin
     ```
     curl https://downloads.dcos.io/binaries/cli/linux/x86-64/0.4.15/dcos > /usr/local/bin/dcos
     ```

  1. Create a virtualenv to run ansible
     ```
     $ pip install virtualenvwrapper
     $ virtualenv -p /usr/bin/python2.7 ~/.venv
     $ source ~/.venv/bin/activate
     ```

     *Note: add `source ~/.venv/bin/activate` to your .bashrc*

  1. Configure virtualenv for ansible
     ```
     (.venv) $ pip install -r requirements.txt
     ```
     On OS X, you may need to mess with cryptography:
     ```
     (.venv) $ LDFLAGS="-L/usr/local/opt/openssl/lib" pip install cryptography --no-use-wheel
     ```

  1. Optionally, enable caching for OpenStack ansible module.

     To configure a caching for one hour for example, add this to your ~/.config/openstack/clouds.yaml
     file:

     ```
     cache:
       expiration_time: 3600
     ```

## Provision Development Mesos Cluster

  1. Set up your environment for sandbox use

     The following 2 steps will be required for any new shell you want to run
     ansible commands in.

     Activate the python virtualenv:
     ```
     $ source ~/.venv/bin/activate
     ```

     Set OpenStack environment variables by sourcing the OpenStack RC file you
     downladed as part of the Development Setup steps:
     ```
     (.venv) $ source /path/to/myproject-openrc.sh
     ```

  1. Create instances
     ```
     (.venv) $ ansible-playbook -i dev-mesos-nce provision-openstack.yml
     ```

  1. Deploy mesos cluster

     ```
     (.venv) $ ansible-playbook -i dev-mesos-nce mesos-cluster.yml
     ```

  1. Configure dcoscli

     Find the floating IP address of your mesos master. Here's one way using the
     nova client, the floating IP is shown as the last address in this
     example output:
     ```
     (.venv) $ nova list --name mesos-master --field networks
     +-------------+----------------------------------------------+
     | ID          | Networks                                     |
     +-------------+----------------------------------------------+
     | 8454e5f7... | default-network=192.168.0.xxx, 71.74.178.yyy |
     +-------------+----------------------------------------------+
     ```

     Now we can configure dcos:
     ```
     (.venv) $ dcos config set core.reporting true
     (.venv) $ dcos config set core.dcos_url http://<FLOATING-IP>
     (.venv) $ dcos config set core.ssl_verify false
     (.venv) $ dcos config set core.timeout 5
     (.venv) $ dcos config set package.cache ~/.dcos/cache
     (.venv) $ dcos config set package.sources '["https://github.com/mesosphere/universe/archive/version-1.x.zip"]'
     (.venv) $ dcos package update
     ```

     *WARNING: this will override any previous settings you had for dcos.*
