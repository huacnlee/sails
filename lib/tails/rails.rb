if not defined?(Rails)
  module Rails
    def self.logger
      Tails.logger
    end

    def self.env
      Tails.env
    end

    def self.cache
      Tails.cache
    end
  end
end