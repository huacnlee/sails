Sails
=====

Sails, create [Thrift](thrift.apache.org) app server like Rails.

[![Build Status](https://travis-ci.org/huacnlee/sails.svg)](https://travis-ci.org/huacnlee/sails) [![Gem Version](https://badge.fury.io/rb/sails.svg)](http://badge.fury.io/rb/sails)

## Features

- Rails style Thrift server;
- Nonblocking mode;
- I18n support;

## Installation

```bash
$ gem install sails
$ sails -h
ENV: development
Commands:
  sails help [COMMAND]  # Describe available commands or one specific command
  sails new APP_NAME    # Create a project
  sails restart         # Restart Thrift server
  sails start           # Start Thrift server
  sails stop            # Stop Thrift server
  sails version         # Show Sails version
```

## Usage

### Create new project

```bash
$ sails new foo
$ cd foo
$ sails start
```

### Generate Thrift IDL

You can edit Thrift IDL in `app_name.thrift`, and then generate it to ruby source code.

```
$ rake gen
```

## Client Connect

```ruby
require "app/services/gen-rb/you_app_name"
@transport ||= Thrift::FramedTransport.new(::Thrift::Socket.new('127.0.0.1', 4000, 10))
@protocol  ||= Thrift::BinaryProtocol.new(@transport)
@client    ||= Thrift::YouAppName::Client.new(@protocol)
@transport.open()
puts @client.ping()
=> Ping pong
```

## Deploy

```
$ sails s --daemon
$ ps aux
jason            2408   0.1  0.2  2648176  13532 s003  S    12:14下午   0:00.02 you_sails_app    
jason            2407   0.0  0.0  2604916   1016 s003  S    12:14下午   0:00.00 you_sails_app [master]
$ sails restart
$ sails stop
```

## API Documents

http://www.rubydoc.info/github/huacnlee/sails


## TODO

- [ ] Reload without restart;
- [ ] Scaffold generator;
- [X] Multi processes;
