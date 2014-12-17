## 0.1.2 / 2014-12-17

- `sails restart` use kill -USR2 signal, not kill master process.
- Use tail log file to instead of direct stdout.
- Add `before_action` support for Service layout;
- Add `params` like same name in ActionController for Service layout;

## 0.1.1 / 2014-12-10

- Add `sails s`, `sails c` commands.
- Refactor service layer, use class to instead module.
- Support to custom Thrift protocol with `config.protocol = :binary`.
- Fix ThriftServer::OperationFailed not found error.
- Implement Master Process to manage and protect Child Process, keep it running/restart/stop, like Unicorn.
- Add Sails.reload! to reload cache classes.
- Sails console start with IRB class, and support `reload!`,`service` methods in console.

## 0.1.0 / 2014-12-9

- First version release.
