require_relative "../lib/sails"

# Force set Sails root to spec/dummy
Sails.root = File.expand_path("../dummy", __FILE__)
$LOAD_PATH.unshift Sails.root

# for test Sails config
module Sails
  config.app_name = 'hello'
  config.thrift_host = '1.1.1.1'
  config.thrift_port = 1000
  config.i18n.default_locale = 'zh-TW'
  config.autoload_paths += %W(app/bar)
  config.cache_store = [:dalli_store, '127.0.0.1']
end

RSpec.configure do |config|

  config.before(:each) do
  end

  config.after(:each) do
  end

  config.raise_errors_for_deprecations!
end
