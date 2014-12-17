module Sails
  module Service
    extend ActiveSupport::Autoload
    
    autoload :Base
    autoload :Config
    autoload :Exception
    autoload :Interface
    autoload :Callbacks
  end
end