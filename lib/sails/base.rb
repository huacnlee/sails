Bundler.require()

# Sails 
#
# You can custom Sails configs in config/application.rb
#
#    module Sails
#      config.app_name = 'you_app_name'
#      config.thrift.port = 7075
#      config.thrift.processor = Thrift::YouAppName::Processor
#      config.thrift.procotol = :binary
#    
#      config.autoload_paths += %W(app/workers)
#    
#      config.i18n.default_locale = 'zh-CN'
#    
#      # cache store
#      config.cache_store = [:dalli_store, '127.0.0.1' }]
#    end
#
module Sails
  extend ActiveSupport::Autoload
  
  autoload :Config

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
  def self.config
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
  def self.cache
    return @cache if defined?(@cache)
    @cache = ActiveSupport::Cache.lookup_store(self.config.cache_store)
  end

  # Sails.root
  #
  # This method returns a Pathname object which handles paths starting with a / as absolute (starting from the root of the filesystem). Compare:
  # For example:
  #   >> Sails.root
  #   => #<Pathname:/some/path/to/project>
  #   >> Sails.root + "file"
  #   => #<Pathname:/some/path/to/project/file>
  def self.root
    @root ||= Pathname.new(Dir.pwd)
  end
  
  def self.root=(root)
    @root = Pathname.new(root)
  end

  # Sails.env
  #
  # returns a string representing the current Sails environment.
  # This will read from ENV['RAILS_ENV'] like Rails
  # For example:
  #
  #     Sails.env # in development mode
  #     => "development"
  #     Sails.env.development?
  #     => true
  def self.env
    @env ||= ActiveSupport::StringInquirer.new(ENV['RAILS_ENV'].presence || 'development')
  end

  # Sails.logger
  #
  # returns a Logger class
  # For example:
  #
  #     Sails.logger.info "Hello world"
  #     Sails.logger.error "Hello world"
  def self.logger
    return @logger if defined?(@logger)
    @logger = Logger.new(File.join(Sails.root, "log/#{self.env}.log"))
    @logger.formatter = proc { |severity, datetime, progname, msg|
      self.stdout_logger.info msg if !Sails.env.test?
      "#{msg}\n"
    }
    @logger
  end

  def self.init
    $:.unshift self.root.join("lib")
    # init root
    return false if @inited == true

    self.root

    ActiveSupport::Dependencies.autoload_paths += Sails.config.autoload_paths

    env_file = self.root.join('config/environments/',Sails.env)
    if File.exist?(env_file)
      require env_file
    end

    require "sails/service"

    puts "ENV: #{Sails.env}"

    load_initialize
    @inited = true
  end

  def self.start!(type)
    if type == "thread"
      start_thread_pool_server!
    else
      start_non_blocking_server!
    end
  end

  def self.service
    @service ||= Sails::Service::Interface.new
  end
  
  def self.thrift_protocol_class
    case config.protocol
    when :compact
      return ::Thrift::CompactProtocolFactory
    else 
      return ::Thrift::BinaryProtocolFactory
    end
  end

  def self.start_thread_pool_server!
    transport = ::Thrift::ServerSocket.new(nil, config.thread_port)
    transport_factory = ::Thrift::BufferedTransportFactory.new
    protocol_factory = thrift_protocol_class.new
    processor = config.thrift.processor.new(self.service)
    server = ::Thrift::ThreadPoolServer.new(processor, transport, transport_factory, protocol_factory, Setting.pool_size)

    puts "Boot on: #{Sails.root}"
    puts "[#{Time.now}] Starting the Sails with ThreadPool size: #{Setting.pool_size}..."
    puts "serve: 127.0.0.1:#{config.thread_port}"

    begin
      server.serve
    rescue => e
      puts "Start thrift server exception! \n  #{e.inspect}"
      puts e.backtrace

      if self.env != "development"
        sleep 2
        retry
      end
    end
  end

  def self.start_non_blocking_server!
    transport = ::Thrift::ServerSocket.new(nil, config.port)
    transport_factory = ::Thrift::FramedTransportFactory.new
    protocol_factory = thrift_protocol_class.new
    processor = config.processor.new(self.service)
    server = ::Thrift::NonblockingServer.new(processor, transport, transport_factory)

    puts "Boot on: #{Sails.root}"
    puts "[#{Time.now}] Starting the Sails with NonBlocking..."
    puts "serve: 127.0.0.1:#{config.port}"

    begin
      server.serve
    rescue => e
      puts "Start thrift server exception! \n  #{e.inspect}"
      puts e.backtrace

      if self.env != "development"
        sleep 2
        retry
      end
    end
  end
  
  private
  def self.stdout_logger
    return @stdout_logger if defined?(@stdout_logger)
    @stdout_logger = Logger.new(STDOUT)
    @stdout_logger.formatter = proc { |severity, datetime, progname, msg|
      "#{msg}\n"
    }
    @stdout_logger
  end

  def self.load_initialize
    Dir["#{Sails.root}/config/initializers/*.rb"].each do |f|
      require f
    end
  end
end

Sails.init()