nsg.graphite
========

[![Build Status](https://travis-ci.org/nsg/ansible-graphite.svg?branch=master)](https://travis-ci.org/nsg/ansible-graphite)

This role installs graphite, I choose to install graphite from pip because the packages in the distributions repositories are old and features are missing. I’m using apt/yum when possible.

Requirements
------------

As usual, read the tasks and make sure this role will not breaks your installation, I will for example mess with django, twisted and uwsgi.

This role exposes the graphite web interface with uwsgi at `localhost:3031`, you need to configure a web server your self to talk to that. For example, do this with nginx:

```
server {
  listen 8080;
  charset utf-8;
  access_log /var/log/nginx/graphite.access.log;
  error_log /var/log/nginx/graphite.error.log;

  location / {
  include uwsgi_params;
  uwsgi_pass 127.0.0.1:3031;
  }
}
```

The uwsgi socket can be configured through `uwsgi_graphite_socket`.

Alternatively, you can define `uwsgi_graphite_extraopts` with additional uwsgi configuration, which can e.g. enable http on port 8080 or add basic auth:
```yaml
uwsgi_graphite_extraopts:
  - option: http
    value: "{{ ansible_default_ipv4.address }}:8080"
  - option: plugins
    value: router_basicauth
  - option: route
    value: "^/ basicauth:myRealm,foo:bar"
```

Role Variables
--------------

* `graphite_user` - The user that carbon and uwsgi is executed as, default: `graphite`
* `graphite_secret_key` - Change this to a random string, default: `UNSAFE_DEFAULT`
* `graphite_time_zone` - Select timezone, default: `America/Los_Angeles`
* `graphite_admin_date_joined`, default: `"2014-07-21T10:11:17.464"`
* `graphite_admin_email`, default: `"root@localhost"`
* `graphite_admin_first_name`, default: `""`
* `graphite_admin_last_name`, default: `""`
* `graphite_admin_last_login`, default: `"2014-07-21T10:11:17.464"`
* `graphite_admin_username`, default: `"admin"`
* `graphite_admin_password`, default: `"admin"`

Example Playbook
-------------------------

```
    - hosts: servers
      roles:
         - { role: nsg.graphite, graphite_secret_key: 'dgdgdfgasg' }
```

... or place graphite_secret_key in group_vars, host_vars, inventory...

License
-------

MIT

Author Information
------------------

Stefan Berggren, nsg@nsg.cc
