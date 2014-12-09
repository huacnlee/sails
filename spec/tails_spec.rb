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
  
  describe '#logger' do
    it 'should be a Logger class' do
      expect(Sails.logger).to be_a(Logger)
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
  
end