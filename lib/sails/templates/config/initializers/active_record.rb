require "active_record"
ActiveRecord::Base.raise_in_transactional_callbacks = true

config_file = Sails.root.join("config/database.yml")
database_config = YAML.load_file(config_file)[Sails.env]
ActiveRecord::Base.establish_connection(database_config)