require 'java'

module Pacer::Orient
  class Encoder
    JavaDate = java.util.Date
    JavaSet = java.util.Set
    JavaMap = java.util.Map
    JavaList = java.util.List

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
      when JavaDate, Time
        value
      when DateTime, Date
        value.to_time
      when Set
        value.to_hashset
      when Hash
        value.to_hash_map
      when Enumerable
        value.to_list
      when JavaSet, JavaMap, JavaList
        value
      else
        Marshal.dump(value).to_java_bytes
      end
    end

    def self.decode_property(value)
      puts value.class
      case value
      when ArrayJavaProxy
        Marshal.load String.from_java_bytes(value)
      when JavaDate
        Time.at(value.getTime() / 1000.0).utc
      when JavaSet
        value.to_set
      when JavaMap
        Hash[value]
      when JavaList
        value.to_a
      else
        value
      end
    end
  end
end
