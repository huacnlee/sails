module Sails
  module Service
    # Like ActionController::Base
    class Base
      include Callbacks
      
      class << self
        def internal_methods
          controller = self.superclass
          controller.public_instance_methods(true)
        end
        
        def action_methods
          @action_methods ||= begin
            # All public instance methods of this class, including ancestors
            methods = (public_instance_methods(true) -
              # Except for public instance methods of Base and its ancestors
              internal_methods +
              # Be sure to include shadowed public instance methods of this class
              public_instance_methods(false)).uniq.map(&:to_s)

            # Clear out AS callback method pollution
            Set.new(methods.reject { |method| method =~ /_one_time_conditions/ })
          end
        end
      end
      
      # action params to Hash
      #
      # example:
      # 
      #    class FooService < Sails::Service::Base
      #       def foo(name, age)
      #         # you can use params in any instance methods
      #         puts params[:name]
      #         puts params[:age]
      #       end
      #    end
      #
      def params
        @params ||= {}
      end
      
      # Raise a Sails::Service::Exception (Thrift::Exception)
      # if you want custom error you can override this method in you ApplicationService
      def raise_error(code, msg = nil)
        raise Exception.new(code: code, message: msg)
      end
      
      def action_methods
        self.class.action_methods
      end

      # Sails.logger
      # You can use this method in app/services
      def logger
        Sails.logger
      end
    end
  end
end
