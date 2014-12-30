Bundler.require

module Sails
  extend ActiveSupport::Autoload

  autoload :Config

  class << self
    # Sails.config
    #
    # Configs with Sails
    # For example:
    #
    #   Sails.config.app_name
    #   # => returns "You App Name"
    #
    #   Sails.config.autoload_paths
    #   # => returns ['app/models','app/models/concerns', 'app/workers', 'app/services'...]
    #
    #   Sails.config.cache_store = [:dalli_store, '127.0.0.1', { pool_size: 100 }]
    #   Sails.config.i18n.default_locale = 'zh-CN'
    #
    def config
      return @config if defined?(@config)
      @config = Config.new.config
    end

    # Sails.cache
    #
    # An abstract cache store class. There are multiple cache store
    # implementations, each having its own additional features. See the classes
    # under the ActiveSupport::Cache module, e.g.
    # ActiveSupport::Cache::MemCacheStore. MemCacheStore is currently the most
    # popular cache store for large production websites.
    #
    # Some implementations may not support all methods beyond the basic cache
    # methods of +fetch+, +write+, +read+, +exist?+, and +delete+.
    #
    # ActiveSupport::Cache::Store can store any serializable Ruby object.
    #
    #   Sails.cache.read('city')   # => nil
    #   Sails.cache.write('city', "Duckburgh")
    #   Sails.cache.read('city')   # => "Duckburgh"
    #
    # Keys are always translated into Strings and are case sensitive. When an
    # object is specified as a key and has a +cache_key+ method defined, this
    # method will be called to define the key.  Otherwise, the +to_param+
    # method will be called. Hashes and Arrays can also be used as keys. The
    # elements will be delimited by slashes, and the elements within a Hash
    # will be sorted by key so they are consistent.
    #
    #   Sails.cache.read('city') == Sails.cache.read(:city)   # => true
    #
    # Nil values can be cached.
    def cache
      return @cache if defined?(@cache)
      @cache = ActiveSupport::Cache.lookup_store(self.config.cache_store)
    end

    # Sails.root
    #
    # This method returns a Pathname object which handles paths starting with a / as absolute (starting from the root of the filesystem). Compare:
    #
    # For example:
    #   >> Sails.root
    #   => #<Pathname:/some/path/to/project>
    #   >> Sails.root + "file"
    #   => #<Pathname:/some/path/to/project/file>
    #
    def root
      return @root if defined?(@root)
      path = `pwd -L`.sub(/\n/,'') rescue Dir.pwd
      @root ||= Pathname.new(path)
    end

    def root=(root)
      @root = Pathname.new(root)
    end

    # Sails.env
    #
    # returns a string representing the current Sails environment.
    # This will read from ENV['RAILS_ENV'] like Rails
    #
    # For example:
    #
    #     Sails.env # in development mode
    #     => "development"
    #     Sails.env.development?
    #     => true
    #
    def env
      @env ||= ActiveSupport::StringInquirer.new(ENV['RAILS_ENV'].presence || 'development')
    end

    # Sails.logger
    #
    # returns a Logger class
    # For example:
    #
    #     Sails.logger.info "Hello world"
    #     Sails.logger.error "Hello world"
    #
    def logger
      return @logger if defined?(@logger)
      @logger = Logger.new(logger_path)
      @logger.formatter = proc { |severity, datetime, progname, msg|
        "#{msg}\n"
      }
      @logger
    end
  
    def logger_path
      @logger_path ||= Sails.root.join("log/#{self.env}.log")
    end

    def init
      # init root
      return false if @inited == true
      $:.unshift self.root.join("lib")

      self.root
      self.check_create_dirs

      ActiveSupport::Dependencies.autoload_paths += Sails.config.autoload_paths

      env_file = self.root.join('config/environments/',Sails.env + ".rb")
      if File.exist?(env_file)
        require env_file
      end

      require "sails/service"

      self.load_initialize
      @inited = true
    end

    # Sails.service
    #
    # return a instance of Sails Service layer
    #
    # for example:
    #
    #     class UsersService < Sails::Service::Base
    #       def check_name_exist?(name)
    #         User.check_name_exist?(name)
    #       end
    #     end
    #
    #     class UsersServiceTest
    #       def test_check_name_exist?
    #         assert_equal(Sails.service.check_name_exist?(name), true)
    #       end
    #     end
    #
    def service
      @service ||= Sails::Service::Interface.new
    end

    # Force reload Sails cache classes in config.autoload_paths
    def reload!(opts = {})
      force = opts[:force] || false
      if force || config.cache_classes == false
        # @service = nil
        ActiveSupport::Dependencies.clear
        # reload_server!
      end
      true
    end

    def reload_server!
      if @server
        new_processor = config.processor.new(self.service)
        @server.instance_variable_set(:@processor, new_processor)
      end
    end

    def start!(type)
      logger.info "ENV: #{Sails.env}"

      @server_type = type
      if @server_type == "thread"
        start_thread_pool_server!
      else
        start_non_blocking_server!
      end
    end

    def thrift_protocol_class
      case config.protocol
      when :compact
        return ::Thrift::CompactProtocolFactory
      when :json
        return ::Thrift::JsonProtocolFactory
      else
        return ::Thrift::BinaryProtocolFactory
      end
    end

    # Start Thrift Server with Threaded mode
    #
    def start_thread_pool_server!
      transport = ::Thrift::ServerSocket.new(nil, config.thread_port)
      transport_factory = ::Thrift::BufferedTransportFactory.new
      protocol_factory = thrift_protocol_class.new
      processor = config.processor.new(self.service)
      @server = ::Thrift::ThreadPoolServer.new(processor, transport, transport_factory, protocol_factory, config.thread_size)

      logger.info "Boot on: #{Sails.root}"
      logger.info "[#{Time.now}] Starting the Sails with ThreadPool size: #{Setting.pool_size}..."
      logger.info "serve: 127.0.0.1:#{config.thread_port}"

      begin
        @server.serve
      rescue => e
        puts "Start thrift server exception! \n  #{e.inspect}"
        puts e.backtrace
      end
    end

    # Start Thrift Server with Event drive mode
    def start_non_blocking_server!
      transport = ::Thrift::ServerSocket.new(nil, config.port)
      transport_factory = ::Thrift::FramedTransportFactory.new
      protocol_factory = thrift_protocol_class.new
      processor = config.processor.new(self.service)
      @server = ::Thrift::NonblockingServer.new(processor, transport, transport_factory, protocol_factory, config.thread_size)

      logger.info "Boot on: #{Sails.root}"
      logger.info "[#{Time.now}] Starting the Sails with NonBlocking..."
      logger.info "Protocol: #{thrift_protocol_class.name}"
      logger.info "serve: 127.0.0.1:#{config.port}"

      begin
        @server.serve
      rescue => e
        puts "Start thrift server exception! \n  #{e.inspect}"
        puts e.backtrace
      end
    end

    def load_initialize
      Dir["#{Sails.root}/config/initializers/*.rb"].each do |f|
        require f
      end
    end
  
    def check_create_dirs
      %w(log tmp tmp/cache tmp/pids).each do |name|
        if not Dir.exist? Sails.root.join(name)
          require "fileutils"
          dir_path = Sails.root.join(name)
          FileUtils.mkdir_p dir_path
          FileUtils.touch [dir_path,".keep"].join("/")
        end
      end
    end
  end
end

Sails.init
