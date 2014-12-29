require 'rubygems'
require 'bundler/setup'
require 'active_support/all'
require 'i18n'
require 'thrift'
require 'yaml'
require "sails/rails"
require "sails/base"

# Sails 
#
# You can custom Sails configs in config/application.rb
#
#    module Sails
#      config.app_name = 'you_app_name'
#      config.thrift.port = 7075
#      config.thrift.processor = Thrift::YouAppName::Processor
#
#      # Thrift Protocols can be use [:binary, :compact, :json]
#      # http://jnb.ociweb.com/jnb/jnbJun2009.html#protocols
#      config.thrift.procotol = :binary
#    
#      config.autoload_paths += %W(app/workers)
#    
#      config.i18n.default_locale = 'zh-CN'
#    
#      # cache store
#      config.cache_store = [:dalli_store, '127.0.0.1' }]
#    end
#
module Sails
  extend ActiveSupport::Autoload
  
  autoload :Config
  autoload :Version
  autoload :Service
  autoload :CLI
  autoload :Daemon
  autoload :Console

  eager_autoload do
    autoload :LogSubscriber
  end
end

Sails.eager_load!