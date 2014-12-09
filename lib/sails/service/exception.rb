module Sails
  module Service
    # Thrift Exception
    class Exception < ::Thrift::Exception
      include ::Thrift::Struct, ::Thrift::Struct_Union
      CODE = 1
      MESSAGE = 2

      FIELDS = {
        CODE => {:type => ::Thrift::Types::I32, :name => 'code'},
        MESSAGE => {:type => ::Thrift::Types::STRING, :name => 'message'}
      }

      def struct_fields; FIELDS; end

      def validate
      end

      ::Thrift::Struct.generate_accessors self
    end
  end
end