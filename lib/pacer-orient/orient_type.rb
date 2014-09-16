module Pacer::Orient
  class OrientType
    extend Forwardable

    attr_reader :graph, :element_type, :type

    # TODO: setters like in Property, once I figure out what these settings do.

    def_delegators :@type,
      :name, :short_name, :type_name, :abstract?, :strict_mode?,
      :base_classes,
      :class_indexes, :indexes, :involved_indexes,
      :size, :over_size,
      :cluster_selection, :cluster_ids,
      :custom_keys, :custom

    alias class_indices class_indexes
    alias indices indexes
    alias involved_indices involved_indexes

    def initialize(graph, element_type, type)
      @graph = graph
      @element_type = type
      @type = type
    end

    def raw_property(name)
      if name.is_a? Symbol or name.is_a? String
        type.getProperty name.to_s
      else
        name
      end
    end

    def property(name)
      p = raw_property(name)
      Property.new self, p if p
    end

    def property!(name, otype = :any)
      p = raw_property(name)
      unless p
        p = graph.send(:in_pure_transaction) do
          type.createProperty(name, graph.property_type(otype))
        end
      end
      Property.new self, p
    end

    def super_class
      if base_classes.any?
        OrientType.new graph, type.getSuperClass
      end
    end

    def set_super_class(sc)
      type.setSuperClass graph.orient_type(element_type, sc)
      self
    end

    def drop_property!(name)
      type.dropProperty name
    end

    def properties
      type.properties.map { |p| Property.new self, p }
    end

    def indexed_properties
      type.indexedProperties.map { |p| Property.new self, p }
    end

    def inspect
      abs = "Abstract" if abstract?
      strict = " (strict)" if strict_mode?
      "#<#{ abs }#{ type_name.capitalize }Type #{ name }#{ strict }>"
    end
  end
end
