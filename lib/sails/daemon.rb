module Sails
  class Daemon
    class << self
      attr_accessor :options, :mode, :app_name, :pid_file

      def init(opts = {})
        self.app_name = Sails.config.app_name
        self.mode = opts[:mode]
        self.app_name = "#{Sails::Daemon.app_name}-thread" if self.mode == "thread"
        self.pid_file = Sails.root.join("tmp/#{Sails::Daemon.app_name}.pid")
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
end