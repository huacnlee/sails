require 'spec_helper'

describe 'Sails::CLI' do
  let(:cli) { Sails::CLI.new }
  describe '.start' do
    it { expect(cli).to respond_to(:start) }
    it {
      expect(Sails::Daemon).to receive(:init)
      expect(Sails::Daemon).to receive(:start_process)
      cli.start
    }
  end
  
  describe '.stop' do
    it { expect(cli).to respond_to(:stop) }
    it {
      expect(Sails::Daemon).to receive(:init)
      expect(Sails::Daemon).to receive(:stop_process)
      cli.stop
    }
  end
  
  describe '.restart' do
    it { expect(cli).to respond_to(:restart) }
    it {
      # expect(Sails::Daemon).to receive(:init)
      expect(Sails::Daemon).to receive(:stop_process)
      expect(Sails::Daemon).to receive(:start_process)
      cli.restart
    }
  end
  
  describe '.new' do
    it { expect(cli).to respond_to(:new) }
  end
  
  describe '.console' do
    it { expect(cli).to respond_to(:console) }
  end
  
  describe '.version' do
    it { expect(cli).to respond_to(:version) }
  end
end