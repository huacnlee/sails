require 'rubygems'
require 'bundler/setup'
require 'active_support/all'
require 'i18n'
require 'thrift'
require 'yaml'
require "sails/rails"
require "sails/base"

module Sails
  extend ActiveSupport::Autoload
  
  autoload :Config
  autoload :Version
  autoload :Service
  autoload :CLI
  autoload :Daemon
end