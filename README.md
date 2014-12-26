Sails
=====

Sails, create [Thrift](http://thrift.apache.org) app server like Rails.

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
$ rake generate
```

## Rake tasks

```bash
rake client:ping            # client ping test
rake db:create              # Creates the database from DATABASE_URL or config/database.yml for the current RAILS_ENV (use db:create:all to create all databases in the config)
rake db:drop                # Drops the database from DATABASE_URL or config/database.yml for the current RAILS_ENV (use db:drop:all to drop all databases in the config)
rake db:fixtures:load       # Load fixtures into the current environment's database
rake db:migrate             # Migrate the database (options: VERSION=x, VERBOSE=false, SCOPE=blog)
rake db:migrate:create      # Create new migration file
rake db:migrate:status      # Display status of migrations
rake db:rollback            # Rolls the schema back to the previous version (specify steps w/ STEP=n)
rake db:schema:cache:clear  # Clear a db/schema_cache.dump file
rake db:schema:cache:dump   # Create a db/schema_cache.dump file
rake db:schema:dump         # Create a db/schema.rb file that is portable against any DB supported by AR
rake db:schema:load         # Load a schema.rb file into the database
rake db:seed                # Load the seed data from db/seeds.rb
rake db:setup               # Create the database, load the schema, and initialize with the seed data (use db:reset to also drop the database first)
rake db:structure:dump      # Dump the database structure to db/structure.sql
rake db:structure:load      # Recreate the databases from the structure.sql file
rake db:version             # Retrieves the current schema version number
rake generate               # Generate code from thrift IDL file
```

## Client connect to test

You can write test code in `lib/tasks/client.rake` to test your thrift methods.

And then start sails server, and run rake task to test, for example:

```bash
sails s --daemon
rake client:ping
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
- [ ] Thrift Server Nonblocking mode have bug;
- [ ] Default test case templates;
- [ ] Client rake task to test services;
