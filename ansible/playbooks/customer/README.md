# Customer Onboarding Playbooks

Refer to https://confluence.cloud.twc.net/display/CSAS/New+Customer+Setup for the steps required to onboard a customer.

## General Usage

There are two playbooks for customer management: `setup.yml` and `cleanup.yml`. The former provisions customer resources, the latter removes those resources.

To provision a customer run:

```
ansible-playbook \
  -i prod-mesos-<region> \
  -e customer_name=<customername> \
  ./playbooks/customer/setup.yml
```

Substitute the correct `<region>` and the `<customername>` that matches a filename in `playbooks/customers/vars/` (without the yml extension).

Follow the same pattern to remove the customer's resources:

```
ansible-playbook \
  -i prod-mesos-<region> \
  -e customer_name=<customername> \
  ./playbooks/customer/cleanup.yml
```
