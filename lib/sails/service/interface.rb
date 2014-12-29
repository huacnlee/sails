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
        instance.params[:method_name] = method_name
        method_args.each_with_index do |arg, idx|
          instance.params[arg] = args[idx]
        end
      end

      def run_action(instance, method_name, *args, &block)
        set_params_with_method_args(instance, method_name, args)
        instance.run_callbacks :action do
          time = Time.now.to_f
          
          raw_payload = {
            controller: instance.class.to_s,
            action: method_name,
            params: instance.params,
          }

          ActiveSupport::Notifications.instrument("start_processing.sails", raw_payload.dup)
          ActiveSupport::Notifications.instrument("process_action.sails", raw_payload) do |payload|
            begin
              res = instance.send(method_name, *args, &block)
              payload[:code] = 200
              return res
            rescue Thrift::Exception => e
              payload[:code] = e.try(:code)
              raise e
            rescue => e
              if e.class.to_s == "ActiveRecord::RecordNotFound"
                payload[:code] = 404
              else
                payload[:code] = 500
              
                Sails.logger.info "  ERROR #{e.inspect} backtrace: \n  #{e.backtrace.join("\n  ")}"
              end
            
              instance.raise_error(payload[:code])
            ensure
              ActiveRecord::Base.clear_active_connections! if defined?(ActiveRecord::Base)
            end
          end
        end
      end
    end
  end
end