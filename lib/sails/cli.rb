require 'thor'
require 'sails/version'

module Sails
  class CLI < Thor
    include Thor::Actions
    
    map '-v' => :version
    map 's' => :start
    map 'c' => :console

    def self.source_root
      __dir__
    end
    
    no_commands {
      def app_name
        @app_name
      end
    }

    option :daemon, type: :boolean, default: false
    option :mode, default: 'nonblocking'
    desc "start", "Start Thrift server"
    def start()
      Sails::Daemon.init(mode: options[:mode])
      Sails::Daemon.start_process(daemon: options[:daemon])
    end

    option :mode, default: 'nonblocking'
    desc "stop", "Stop Thrift server"
    def stop()
      Sails::Daemon.init(mode: options[:mode])
      Sails::Daemon.stop_process
    end

    option :mode, default: 'nonblocking'
    desc "restart", "Restart Thrift server"
    def restart()
      Sails::Daemon.init(mode: options[:mode])
      Sails::Daemon.stop_process
      Sails::Daemon.start_process(daemon: true)
    end

    desc "new APP_NAME", "Create a project"
    def new name
      require 'fileutils'

      app_dir = File.expand_path File.join(Dir.pwd, name)
      @rel_dir = name
      @app_name = File.basename app_dir
      templte_dir = File.join(File.dirname(__FILE__), "templates")

      directory 'templates', name
      %W(log tmp/pids tmp/cache lib/tasks app/models/concerns config/initializers log).each do |dir_name|
        empty_directory File.join(app_dir,dir_name)
      end
      puts ''
    ensure
      @app_name = nil
      @rel_dir = nil
    end
    
    desc "console", "Enter Sails console"
    def console
      system "pry -I config/application.rb -r ./config/application.rb"
    end
    
    desc "version", "Show Sails version"
    def version
      puts "Sails #{Sails.version}"
    end
  end
end
