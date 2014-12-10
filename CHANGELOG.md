## 0.1.1

- Add `sails s`, `sails c` commands.
- Refactor service layer, use class to instead module.
- Support to custom Thrift protocol with `config.protocol = :binary`.
- Fix ThriftServer::OperationFailed not found error.
- Implement Master Process to manage and protect Child Process, keep it running/restart/stop, like Unicorn.

## 0.1.0 / 2014-12-9

- First version release.