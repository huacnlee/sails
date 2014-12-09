module Sails
  class Service
    include ActiveSupport::Callbacks
    define_callbacks :action

    set_callback :action, :before do |object|
    end

    set_callback :action, :after do |object|
      ActiveRecord::Base.clear_active_connections! if defined?(ActiveRecord::Base)
    end

    def method_missing(method_name, *args, &block)
      run_callbacks :action do
        time = Time.now.to_f

        Sails.logger.info "\nProcessing by \"#{method_name}\" at #{Time.now.to_s}" unless Sails.env.test?
        Sails.logger.info "  Parameters: { #{args.map(&:inspect).join(', ')} }" unless Sails.env.test?

        begin
          res = interface.send(method_name, *args, &block)
          status = "Completed"
          return res
        rescue ActiveRecord::RecordNotFound => e
          status = "Not Found"
          interface.raise_error(-1004)
        rescue ThriftServer::OperationFailed => e
          status = "Failed #{e.code}"
          raise e
        rescue => e
          status = "Error 500"
          Sails.logger.info "\"#{method_name}\" error : #{e.inspect}\n\n"
          Sails.logger.info %Q(backtrace: #{e.backtrace.join("\n")}\n)
          interface.raise_error(-1000)
        ensure
          elapsed = format('%.3f', (Time.now.to_f - time) * 1000)
          Sails.logger.info "#{status} in (#{elapsed}ms).\n\n" unless Sails.env.test?
        end
      end
    end

    def args
      @args ||= []
    end

    def initialize(*array)
      args.concat array
    end

    class Interface
      Dir["#{Sails.root.join("app/services")}/*_service.rb"].each do |f|
        next if 'base_service.rb' == File.basename(f)
        if File.basename(f) =~ /^(.*)_service.rb$/
          require f
          mtd = $1.dup
          klass_name = "#{mtd.camelize}Service"
          include klass_name.constantize
        end
      end

      def raise_error code, msg = nil
        raise ThriftServer::OperationFailed.new(
        code: code,
        message: msg
        )
      end

      def logger
        Sails.logger
      end
    end

    def interface
      @interface ||= Interface.new
    end
  end
end
