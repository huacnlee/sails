require 'spec_helper'

describe 'Service' do
  describe 'Interface' do
    class SimpleBaseTestService < Sails::Service::Base
      def bar(a, b)
      end

      def foo(c, d)
        
      end
    end

    module Sails
      module Service
        class Interface
          attr_accessor :services

          def initialize
            @services = []
            @services << SimpleBaseTestService.new
            define_service_methods!
          end
        end
      end
    end

    let(:interface) { Sails::Service::Interface.new }

    describe 'set params' do
      it "should set val" do
        simple = interface.services.first
        interface.bar(1, 2)
        expect(simple.params.size).to eq(3)
        expect(simple.params[:method_name]).to eq('bar')
        expect(simple.params[:a]).to eq(1)
        expect(simple.params[:b]).to eq(2)
      end
      it "shoud clear val before set" do
        simple = interface.services.first
        interface.bar(1, 2)
        interface.foo(3, 4)
        expect(simple.params.size).to eq(3)
        expect(simple.params[:method_name]).to eq('foo')
        expect(simple.params[:c]).to eq(3)
        expect(simple.params[:d]).to eq(4)
      end
    end
  end
end