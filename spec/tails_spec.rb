require "spec_helper"

describe 'Tails' do
  it { expect(Tails.version).not_to be_nil }
  
  describe '#root' do
    it 'should be a Pathname class' do
      expect(Tails.root).to be_a(Pathname)
    end
    
    it 'should support Tails.root.join' do
      expect(Tails.root.join("aaa").to_s).to eq File.join(Dir.pwd, "spec/dummy/aaa")
    end
    
    it 'should work' do
      expect(Tails.root.to_s).to eq File.join(Dir.pwd, "spec/dummy")
    end
  end
  
  describe '#logger' do
    it 'should be a Logger class' do
      expect(Tails.logger).to be_a(Logger)
    end
  end
  
  describe '#config' do
    it 'should work' do
      expect(Tails.config).to be_a(Hash)
      expect(Tails.config.autoload_paths).to be_a(Array)
      expect(Tails.config.app_name).to eq "Tails"
    end
  end
end