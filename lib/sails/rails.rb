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
  end
end