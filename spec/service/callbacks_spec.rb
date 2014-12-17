require 'spec_helper'

describe 'Service' do
  describe 'Callbacks' do
    context 'callback with method_name' do
      class CallbackTest1Service < Sails::Service::Base
        before_action :bar, :dar
        def bar; end
        def dar; end
        def foo; end
      end

      let(:simple) { CallbackTest1Service.new }

      before do
        insert_service(simple)
      end

      it 'should work' do
        expect(simple).to receive(:bar).once
        expect(simple).to receive(:dar).once
        service.foo
      end
    end

    describe 'params' do
      class CallbackTest3Service < Sails::Service::Base
        def foo(a, b)
          return params
        end
      end

      let(:simple) { CallbackTest3Service.new }

      before do
        insert_service(simple)
      end

      it "should work" do
        params = service.foo(1,2)
        expect(params).to include(:a, :b)
        expect(params[:a]).to eq 1
        expect(params[:b]).to eq 2
      end
    end
  end
end
