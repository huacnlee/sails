module Sails
  module Service
    module Callbacks
      extend ActiveSupport::Concern
      
      include ActiveSupport::Callbacks
      
      included do
        define_callbacks :action

        set_callback :action, :before do |object|
          # try to reconnect database
          if defined?(ActiveRecord::Base)
            ActiveRecord::Base.verify_active_connections!
          end
        end

        set_callback :action, :after do |object|
        end
      end

      module ClassMethods
        def before_action(*names, &blk)
          names.each do |name|
            set_callback(:action, :before, name, &blk)
          end
        end
      end
    end
  end
end
