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
      expect(Sails.config.app_name).to eq "Sails"
    end
  end
end