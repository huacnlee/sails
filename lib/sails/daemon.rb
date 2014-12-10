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
        old_pid = read_pid
        if old_pid != nil
          puts "Current have #{app_name} process in running on pid #{old_pid}"
          return
        end

        # start master process
        @master_pid = fork_master_process!
        File.open(pid_file, "w+") do |f|
          f.puts @master_pid
        end
        
        puts "Started #{app_name} on pid: #{@master_pid}"

        if options[:daemon] == false
          Process.waitpid(@master_pid)
        end
      end
      
      def fork_master_process!
        fork do
          $PROGRAM_NAME = self.app_name + " [master]"
          @child_pid = fork_child_process!
  
          Signal.trap("QUIT") { 
            Process.kill("QUIT", @child_pid)
            exit
          }
          
          Signal.trap("USR2") {
            Process.kill("USR2", @child_pid)
          }
  
          loop do
            sleep 1
            begin
              Process.getpgid(@child_pid)
            rescue Errno::ESRCH => e
              # puts "Child not found, will restart..."
              @child_pid = fork_child_process!
            end
          end
        end
      end
      
      def fork_child_process!
        fork do
          $PROGRAM_NAME = self.app_name
          Sails.start!(self.mode)
          
          Signal.trap("USR2") {
            # TODO: reload Sails in current process
            exit
          }
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