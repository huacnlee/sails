require 'rubygems'
require 'bundler/setup'
require 'active_support/all'
require 'i18n'
require 'thrift'
require 'yaml'

Bundler.require()

module Tails
  extend ActiveSupport::Autoload

  class Config
    include ActiveSupport::Configurable
  end

  def self.config
    return @config if defined?(@config)
    @config = Config.new.config
    @config.app_name = "Tails"
    @config.cache_store = [:memory_store]
    @config.autoload_paths = %W(app/models app/models/concerns app/workers app/services app/services/concerns lib)
    @config.i18n = I18n
    @config.i18n.load_path += Dir[Tails.root.join('config', 'locales', '*.{rb,yml}').to_s]
    @config.i18n.default_locale = :en
    @config.thrift_processor = nil
    @config
  end

  def self.cache
    return @cache if defined?(@cache)
    @cache = ActiveSupport::Cache.lookup_store(self.config.cache_store)
  end

  # Tails.root
  def self.root
    @root ||= Pathname.new(Dir.pwd)
  end
  
  def self.root=(root)
    @root = Pathname.new(root)
  end

  # Tails.env.development?
  def self.env
    @env ||= ActiveSupport::StringInquirer.new(ENV['RAILS_ENV'].presence || 'development')
  end

  def self.logger
    return @logger if defined?(@logger)
    @logger = Logger.new(File.join(Tails.root, "log/#{self.env}.log"))
    @logger.formatter = proc { |severity, datetime, progname, msg|
      self.stdout_logger.info msg if !Tails.env.test?
      "#{msg}\n"
    }
    @logger
  end

  def self.stdout_logger
    return @stdout_logger if defined?(@stdout_logger)
    @stdout_logger = Logger.new(STDOUT)
    @stdout_logger.formatter = proc { |severity, datetime, progname, msg|
      "#{msg}\n"
    }
    @stdout_logger
  end

  def self.load_initialize
    Dir["#{Tails.root}/config/initializers/*.rb"].each do |f|
      require f
    end
  end

  def self.init
    $:.unshift self.root.join("lib")
    # init root
    return false if @inited == true

    self.root

    ActiveSupport::Dependencies.autoload_paths += Tails.config.autoload_paths

    env_file = self.root.join('config/environments/',Tails.env)
    if File.exist?(env_file)
      require env_file
    end

    require "tails/service"

    puts "ENV: #{Tails.env}"

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
    @service ||= Tails::Service.new
  end

  def self.start_thread_pool_server!
    transport = ::Thrift::ServerSocket.new(nil, config.thrift_thread_port)
    transport_factory = ::Thrift::BufferedTransportFactory.new
    protocol_factory = ::Thrift::BinaryProtocolFactory.new
    processor = config.thrift_processor.new(self.service)
    server = ::Thrift::ThreadPoolServer.new(processor, transport, transport_factory, protocol_factory, Setting.pool_size)

    puts "Boot on: #{Tails.root}"
    puts "[#{Time.now}] Starting the Tails with ThreadPool size: #{Setting.pool_size}..."
    puts "serve: #{config.thrift_host}:#{config.thrift_thread_port}"

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
    transport = ::Thrift::ServerSocket.new(nil, config.thrift_port)
    transport_factory = ::Thrift::FramedTransportFactory.new
    protocol_factory = ::Thrift::BinaryProtocolFactory.new
    processor = config.thrift_processor.new(self.service)
    server = ::Thrift::NonblockingServer.new(processor, transport, transport_factory)

    puts "Boot on: #{Tails.root}"
    puts "[#{Time.now}] Starting the Tails with NonBlocking..."
    puts "serve: #{config.thrift_host}:#{config.thrift_port}"

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
end