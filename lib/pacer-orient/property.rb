module Pacer::Orient
  class Property
    extend Forwardable

    attr_reader :el_type, :property

    def_delegators :@property,
      :name, :full_name, :not_null?, :collate,
      :mandatory?, :readonly?, :min, :max, :index,
      :indexed?, :regexp, :type, :custom, :custom_keys

    def initialize(el_type, property)
      @el_type = el_type
      @property = property
    end

    def graph
      el_type.graph
    end

    def create_index!(index_type = :not_unique)
      unless indexed?
        graph.send(:in_pure_transaction) do
          property.createIndex graph.index_type(index_type)
        end
      end
      self
    end

    def drop_index!
      graph.drop_key_index name if indexed?
      self
    end

    def set_type!(t)
      # Not implemented as of 1.7.8
      fail Pacer::InternalError.new("Type migration is a planned Orient 2.x feature")
    end

    def drop!
      el_type.drop_property! name
      nil
    end

    [ :set_name, :set_not_null, :set_collate,
      :set_mandatory, :set_readonly, :set_min, :set_max,
      :set_regexp, :set_custom, :remove_custom, :clear_custom
    ].each do |setter|
      define_method(setter) do |*args|
        property.send setter, *args
        self
      end
    end

    def inspect
      "#<#{ el_type.type_name.capitalize }Property #{ el_type.name }.#{ property.name } (#{ type })>"
    end
  end
end

