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
      when DateTime, Time, JavaDate
        f = if value.is_a? JavaDate
              value.getTime / 1000.0
            else
              value.to_time.to_f
            end
        i = f.truncate
        r = (f.remainder(1) * 10000).round
        if value.is_a? DateTime
          c = 1
        elsif value.is_a? Time and value.utc?
          c = 2
        else
          c = 3
        end
        ["D", i, r, c].pack("ANnc").to_java_bytes
      when Date
        ["D", value.to_time.to_i].pack("AN").to_java_bytes
      when Set
        value.map { |x| encode_property(x) }.to_hashset
      when Hash
        value.to_hash_map { |k, v| [encode_property(k), encode_property(v)] }
      when Enumerable
        value.map { |x| encode_property(x) }.to_list
      when JavaSet, JavaMap, JavaList
        value
      else
        Marshal.dump(value).to_java_bytes
      end
    end

    def self.decode_property(value)
      case value
      when ArrayJavaProxy
        str = String.from_java_bytes(value)
        flag = str[0]
        case flag
        when 'D'
          data = str.unpack("ANnc")
          i = data[1]
          r = data[2]
          c = data[3]
          if r
            t = Time.at(i + (r / 10000.0))
            case c
            when 1
              t.utc.to_datetime
            when 2
              t.utc
            else
              t
            end
          else
            Time.at(i).utc.to_date
          end
        else
          Marshal.load str
        end
      when JavaDate
        Time.at(value.getTime() / 1000.0)
      when JavaSet
        s = Set[]
        value.each do |v|
          s.add decode_property(v)
        end
        s
      when JavaMap
        h = {}
        value.each do |k, v|
          h[decode_property(k)] = decode_property(v)
        end
        h
      when JavaList
        a = []
        value.each do |v|
          a.push decode_property(v)
        end
        a
      else
        value
      end
    end
  end
end
