require "irb"
require "irb/ext/loader"

module Sails
  module ConsoleMethods
    extend ActiveSupport::Concern
    
    included do
    end
    
    def service
      Sails.service
    end
    
    def reload!
      puts "Reloading..."
      Sails.reload!(force: true)
      true
    end
  end
  
  class Console
    class << self
      def start(app_path)
        new(app_path).start
      end
    end
    
    def initialize(app_path)
      @app_path = app_path
    end
    
    def start
      puts "Loading #{Sails.env} environment (Sails #{Sails.version})"
      IRB.conf[:IRB_NAME] = "Sails console"
      require @app_path
      ARGV.clear
      if defined?(IRB::ExtendCommandBundle)
        IRB::ExtendCommandBundle.send :include, Sails::ConsoleMethods
      end
      IRB.start
    end
  end
end
