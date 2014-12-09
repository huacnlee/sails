require "spec_helper"

describe 'Service' do
  class SimpleService < Sails::Service::Base
    def foo
    end
    
    def bar
    end
    
    private
    def dar
    end
  end
  
  let(:simple) { SimpleService.new }
  
  describe '.raise_error' do
    it { expect(simple).to respond_to(:raise_error) }
    it {
      expect { simple.raise_error(11,'foo') }.to raise_error do |error|
        expect(error).to be_a(Sails::Service::Exception)
        expect(error.code).to eq 11
        expect(error.message).to eq 'foo'
      end
    }
  end
  
  describe '.action_methods' do
    it { expect(simple.action_methods).to include("foo", "bar") }
    it { expect(simple.action_methods.size).to eq 2 }
    it { expect(simple.action_methods).not_to include("dar") }
  end
  
  describe '.logger' do
    it { expect(simple.logger).to eq Sails.logger }
  end
end