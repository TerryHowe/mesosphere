# General purpose migration role
Use this role for ansible code that needs to be run once for clean up or
migration.  When it is merged to master and run in production it can be
replaced with the next migration.  Using this role will make it easier to
track run once migration code.  This role should still be idempotent.
