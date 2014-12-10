module Sails
  class Config
    include ActiveSupport::Configurable
    
    def initialize
      init_defaults!
    end
    
    def init_defaults!
      config.app_name = "Sails"
      config.cache_store = [:memory_store]
      config.autoload_paths = %W(app/models app/models/concerns app/workers app/services app/services/concerns lib)
      config.i18n = I18n
      config.i18n.load_path += Dir[Sails.root.join('config', 'locales', '*.{rb,yml}').to_s]
      config.i18n.default_locale = :en
      config.cache_classes = false
      
      config.port = 4000
      config.thread_port = 4001
      config.processor = nil
      config.thread_size = 20
      config.protocol = :binary
    end
  end
end