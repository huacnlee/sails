module Sails
  module Service
    class Interface
      attr_accessor :services
      
      def initialize
        @services = []
        Dir["#{Sails.root.join("app/services")}/*_service.rb"].each do |f|
          if File.basename(f) =~ /^(.*)_service.rb$/
            require f
            mtd = $1.dup
            klass_name = "#{mtd.camelize}Service"
            @services << klass_name.constantize.new
          end
        end
        define_service_methods!
      end

      private
      def define_service_methods!
        @services.each do |instance|
          instance.action_methods.each do |method_name|
            self.class.send(:define_method, method_name) do |*args, &block|
              run_action(instance, method_name, *args, &block)
            end
          end
        end
      end
      
      def set_params_with_method_args(instance, method_name, args)
        method_args = instance.method(method_name.to_sym).parameters.map { |arg| arg[1] }
        method_args.each_with_index do |arg, idx|
          instance.params[arg] = args[idx]
        end
      end

      def run_action(instance, method_name, *args, &block)
        set_params_with_method_args(instance, method_name, args)
        instance.run_callbacks :action do
          time = Time.now.to_f

          Sails.logger.info "\nProcessing by \"#{method_name}\" at #{Time.now.to_s}" unless Sails.env.test?
          Sails.logger.info "  Parameters: { #{args.map(&:inspect).join(', ')} }" unless Sails.env.test?

          begin
            res = instance.send(method_name, *args, &block)
            status = "Completed"
            return res
          rescue Thrift::Exception => e
            status = "Failed #{e.try(:code)}"
            raise e
          rescue => e
            puts "------- #{e.inspect}"
            if defined?(ActiveRecord) && e.is_a?(ActiveRecord::RecordNotFound)
              status = "Not Found"
              code = 404
            else
              status = "Error 500"
              code = 500
            end
            
            Sails.logger.info "\"#{method_name}\" error : #{e.inspect}\n\n"
            Sails.logger.info %Q(backtrace: #{e.backtrace.join("\n")}\n)
            instance.raise_error(code)
          ensure
            elapsed = format('%.3f', (Time.now.to_f - time) * 1000)
            Sails.logger.info "#{status} in (#{elapsed}ms).\n\n" unless Sails.env.test?
          end
        end
      end
    end
  end
end