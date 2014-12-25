require "spec_helper"

describe 'Sails' do
  it { expect(Sails.version).not_to be_nil }
  
  describe '#root' do
    it 'should be a Pathname class' do
      expect(Sails.root).to be_a(Pathname)
    end
    
    it 'should support Sails.root.join' do
      expect(Sails.root.join("aaa").to_s).to eq File.join(Dir.pwd, "spec/dummy/aaa")
    end
    
    it 'should work' do
      expect(Sails.root.to_s).to eq File.join(Dir.pwd, "spec/dummy")
    end
  end
  
  describe '#init' do
    it 'should work' do
      Sails.instance_variable_set(:@inited, false)
      expect(Sails).to receive(:check_create_dirs).once
      expect(Sails).to receive(:load_initialize).once
      Sails.init
      expect(Sails.instance_variable_get(:@inited)).to eq true
    end
  end
  
  describe '#logger' do
    it 'should be a Logger class' do
      expect(Sails.logger).to be_a(Logger)
    end
    
    it 'should have logger_path' do
      expect(Sails.logger_path).to eq Sails.root.join("log/#{Sails.env}.log")
    end
  end
  
  describe '#config' do
    it 'should work' do
      expect(Sails.config).to be_a(Hash)
      expect(Sails.config.autoload_paths).to be_a(Array)
    end
    
    describe 'Real config' do
      it { expect(Sails.config.app_name).to eq 'hello' }
      it { expect(Sails.config.host).to eq '1.1.1.1' }
      it { expect(Sails.config.port).to eq 1000 }
      it { expect(Sails.config.protocol).to eq :binary }
      it { expect(Sails.config.thread_size).to eq 20 }
      it { expect(Sails.config.i18n.default_locale).to eq :'zh-TW' }
      it { expect(Sails.config.autoload_paths).to include("app/bar") }
    end
  end
  
  describe '#cache' do
    it { expect(Sails.cache).to be_a(ActiveSupport::Cache::DalliStore) }
    it { expect(Sails.cache).to respond_to(:read, :write, :delete, :clear) }
  end
  
  describe '#thrift_protocol_class' do
    it 'should work' do
      allow(Sails.config).to receive(:protocol).and_return(:binary)
      expect(Sails.thrift_protocol_class).to eq ::Thrift::BinaryProtocolFactory
      allow(Sails.config).to receive(:protocol).and_return(:compact)
      expect(Sails.thrift_protocol_class).to eq ::Thrift::CompactProtocolFactory
      allow(Sails.config).to receive(:protocol).and_return(:json)
      expect(Sails.thrift_protocol_class).to eq ::Thrift::JsonProtocolFactory
      allow(Sails.config).to receive(:protocol).and_return(:xxx)
      expect(Sails.thrift_protocol_class).to eq ::Thrift::BinaryProtocolFactory
    end
  end
  
  describe '#reload!' do
    it 'should work' do
      s1 = Sails.service
      Sails.reload!
      # expect(Sails.service).not_to eq s1
      # TODO: test reload autoload_paths
    end
  end
  
  describe '#check_create_dirs' do
    it 'should work' do
      require "fileutils"
      log_path = Sails.root.join("log")
      FileUtils.rm_r(log_path) if Dir.exist?(log_path)
      expect(Dir.exist?(log_path)).to eq false
      
      Sails.check_create_dirs
      %W(log tmp tmp/cache tmp/pids).each do |name|
        expect(Dir.exist?(Sails.root.join(name))).to eq true
      end
    end
  end
  
end