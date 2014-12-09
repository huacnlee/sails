require 'thor'
require 'sails/version'

module Sails
  class ThreadDaemon
    class << self
      attr_accessor :options, :mode, :app_name, :pid_file

      def init(opts = {})
        self.app_name = Sails.config.app_name
        self.mode = opts[:mode]
        self.app_name = "#{ThreadDaemon.app_name}-thread" if self.mode == "thread"
        self.pid_file = Sails.root.join("tmp/#{ThreadDaemon.app_name}.pid")
        self.options = options
      end

      def read_pid
        if !File.exist?(pid_file)
          return nil
        end

        pid = File.open(pid_file).read.to_i
        begin
          Process.getpgid(pid)
        rescue
          pid = nil
        end
        return pid
      end

      def start_process(options = {})
        $PROGRAM_NAME = self.app_name
        old_pid = read_pid
        if old_pid != nil
          puts "Current have #{app_name} process in running on pid #{old_pid}"
          return
        end

        pid = fork do
          Sails.start!(self.mode)
        end
        File.open(pid_file, "w+") do |f|
          f.puts pid
        end

        puts "Started #{app_name} on pid: #{pid}"

        if options[:daemon] == false
          Process.waitpid(pid)
        end
      end

      def stop_process
        pid = read_pid
        if pid == nil
          puts "#{app_name} process not found, pid #{pid}"
          return
        end

        print "Stopping #{app_name} with pid: #{pid}..."
        begin
          Process.kill("QUIT", pid)
        ensure
          File.delete(pid_file)
        end
        puts " [Done]"
      end
    end
  end

  class CLI < Thor
    include Thor::Actions
    
    map '-v' => :version

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
      ThreadDaemon.init(mode: options[:mode])
      ThreadDaemon.start_process(daemon: options[:daemon])
    end

    option :mode, default: 'nonblocking'
    desc "stop", "Stop Thrift server"
    def stop()
      ThreadDaemon.init(mode: options[:mode])
      ThreadDaemon.stop_process
    end

    option :mode, default: 'nonblocking'
    desc "restart", "Restart Thrift server"
    def restart()
      ThreadDaemon.init(mode: options[:mode])
      ThreadDaemon.stop_process
      ThreadDaemon.start_process(daemon: true)
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
