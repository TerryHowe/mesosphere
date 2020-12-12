Entrypoint for single app deployment

Synopsis

   vars:
     app_spec:
       app_name: kibana            # unique name for marathon
       marathon:
         cpus: 0.5                 # number of cpus to allocate per instance
         mem: 512                  # MB of memory to allocate per instance
         instances: 1
         docker:
           image: kibana:4.2.1     # docker image hosted in trusted repo
           environment:            # environment to pass along to container (optional)
             foo: bar
           args:                   # args to pass to container (optional)
             - foo
             - bar
       container_port: 5601      # port exposed within container
       tenant_name: admin          # Avi tenant name that will be managing app
       service_port: 5601          # port to expose service on mesos
       use_floating_ip: false      # whether or not to assign a floating ip
       ssl_cert_name: my-cert      # name of cert in Avi, implies that ssl will be enabled for service
       external: true              # service will be accessed outside mesos cluster
       network: A-Admin-01         # name of a network defined in variable openstack_networks or defaults to the variable default_server_network
       allowed_cidrs:              # list if cidrs that can access service when 'external'
         - 0.0.0.0/0
