if not defined?(Rails)
  module Rails
    def self.logger
      Sails.logger
    end

    def self.env
      Sails.env
    end

    def self.cache
      Sails.cache
    end
    
    def self.root
      Sails.root
    end
  end
end