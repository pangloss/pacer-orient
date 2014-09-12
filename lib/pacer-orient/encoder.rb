require 'java'

module Pacer::Orient
  class Encoder
    JavaDate = java.util.Date

    def self.encode_property(value)
      case value
      when nil
        nil
      when String
        value = value.strip
        value = nil if value == ''
        value
      when Numeric
        if value.is_a? Bignum
          Marshal.dump(value).to_java_bytes
        else
          value.to_java
        end
      when true, false
        value.to_java
      when JavaDate, Date, Time, DateTime
        value
      else
        Marshal.dump(value).to_java_bytes
      end
    end

    def self.decode_property(value)
      if value.is_a? ArrayJavaProxy
        Marshal.load String.from_java_bytes(value)
      else
        value
      end
    end
  end
end
