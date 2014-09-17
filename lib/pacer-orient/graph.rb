require 'set'

require 'pacer-orient/orient_type'
require 'pacer-orient/property'
require 'pacer-orient/encoder'
require 'pacer-orient/record_id'
require 'pacer-orient/factory_container'

module Pacer
  module Orient
    class Graph < PacerGraph
      import com.orientechnologies.orient.core.sql.OCommandSQL
      import com.orientechnologies.orient.core.metadata.schema.OType
      import com.orientechnologies.orient.core.metadata.schema.OClass

      # Marked the types that should be most commonly used.
      OTYPES = {
        :any          => OType::ANY,
        :boolean      => OType::BOOLEAN,      # use this one
        :bool         => OType::BOOLEAN,
        :short        => OType::SHORT,
        :integer      => OType::INTEGER,
        :int          => OType::INTEGER,
        :long         => OType::LONG,         # use this one
        :float        => OType::FLOAT,
        :double       => OType::DOUBLE,       # use this one
        :decimal      => OType::DECIMAL,      # use this one
        :date         => OType::DATE,         # use this one
        :datetime     => OType::DATETIME,     # use this one
        :date_time    => OType::DATETIME,
        :byte         => OType::BYTE,
        :string       => OType::STRING,       # use this one
        :binary       => OType::BINARY,
        :embedded     => OType::EMBEDDED,
        :embeddedlist => OType::EMBEDDEDLIST,
        :embeddedset  => OType::EMBEDDEDSET,
        :embeddedmap  => OType::EMBEDDEDMAP,
        :link         => OType::LINK,
        :linklist     => OType::LINKLIST,
        :linkset      => OType::LINKSET,
        :linkmap      => OType::LINKMAP,
        :linkbag      => OType::LINKBAG,
        :transient    => OType::TRANSIENT,
        :custom       => OType::CUSTOM
      }


      ITYPES = {
        :range_dictionary => OClass::INDEX_TYPE::DICTIONARY,
        :range_fulltext   => OClass::INDEX_TYPE::FULLTEXT,
        :range_full_text  => OClass::INDEX_TYPE::FULLTEXT,
        :range_notunique  => OClass::INDEX_TYPE::NOTUNIQUE,
        :range_not_unique => OClass::INDEX_TYPE::NOTUNIQUE,
        :range_unique     => OClass::INDEX_TYPE::UNIQUE,
        :proxy            => OClass::INDEX_TYPE::PROXY,
        :dictionary       => OClass::INDEX_TYPE::DICTIONARY_HASH_INDEX,
        :fulltext         => OClass::INDEX_TYPE::FULLTEXT_HASH_INDEX,
        :full_text        => OClass::INDEX_TYPE::FULLTEXT_HASH_INDEX,
        :notunique        => OClass::INDEX_TYPE::NOTUNIQUE_HASH_INDEX,
        :not_unique       => OClass::INDEX_TYPE::NOTUNIQUE_HASH_INDEX,
        :spatial          => OClass::INDEX_TYPE::SPATIAL,
        :unique           => OClass::INDEX_TYPE::UNIQUE_HASH_INDEX
      }


      def orient_graph
        blueprints_graph.raw_graph
      end

      def allow_auto_tx=(b)
        blueprints_graph.setAutoStartTx b
      end

      def allow_auto_tx
        blueprints_graph.autoStartTx
      end

      def on_commit(&block)
        return unless block
        # todo
      end

      def on_commit_failed(&block)
        return unless block
        # todo
      end

      def before_commit(&block)
        return unless block
        # todo
      end

      def drop_handler(h)
        # todo
      end

      # NOTE: if you use lightweight edges (they are on by default), g.e will only return edges that have been reified by having properties added to
      # them.
      def lightweight_edges
        blueprints_graph.useLightweightEdges
      end

      alias lightweight_edges? lightweight_edges

      def lightweight_edges=(b)
        blueprints_graph.useLightweightEdges = b
      end

      def use_class_for_edge_label
        blueprints_graph.useClassForEdgeLabel
      end

      def use_class_for_edge_label=(b)
        blueprints_graph.useClassForEdgeLabel = b
      end

      def use_class_for_vertex_label
        blueprints_graph.useClassForVertexLabel
      end

      def use_class_for_vertex_label=(b)
        blueprints_graph.useClassForVertexLabel = b
      end

      def sql(extensions, sql = nil, *args)
        if extensions.is_a? String
          args = args.unshift sql if sql
          sql = extensions
          extensions = []
        end
        sql_command(sql, *args).iterator.to_route(based_on: self.v(extensions))
      end

      def sql_e(extensions, sql = nil, *args)
        if extensions.is_a? String
          args = args.unshift sql if sql
          sql = extensions
          extensions = []
        end
        sql_command(sql, *args).iterator.to_route(based_on: self.e(extensions))
      end

      def sql_command(sql, *args)
        args = args.map { |a| encoder.encode_property(a) }
        blueprints_graph.command(OCommandSQL.new(sql)).execute(*args)
      end

      def orient_type!(t, element_type = :vertex)
        r = orient_type(t, element_type)
        if r
          r
        else
          in_pure_transaction do
            t = if element_type == :vertex
                  blueprints_graph.createVertexType(t.to_s)
                elsif element_type == :edge
                  blueprints_graph.createEdgeType(t.to_s)
                end
            OrientType.new self, element_type, t if t
          end
        end
      end

      def orient_type(t = nil, element_type = :vertex)
        t ||= :V if element_type == :vertex
        t ||= :E if element_type == :edge
        if t.is_a? String or t.is_a? Symbol
          t = if element_type == :vertex
                blueprints_graph.getVertexType(t.to_s)
              elsif element_type == :edge
                blueprints_graph.getEdgeType(t.to_s)
              end
          OrientType.new self, element_type, t if t
        elsif t.is_a? OrientType
          t
        end
      end

      def property_type(t)
        if t.is_a? String or t.is_a? Symbol
          OTYPES[t.to_sym]
        else
          t
        end
      end

      def index_type(t)
        if t.is_a? String or t.is_a? Symbol
          ITYPES[t.to_sym]
        else
          t
        end
      end

      def add_vertex_types(*types)
        in_pure_transaction do
          types.map do |t|
            existing = orient_type(t, :vertex)
            if existing
              existing
            else
              t = blueprints_graph.createVertexType(t.to_s)
              OrientType.new(self, :vertex, t) if t
            end
          end
        end
      end

      def create_key_index(name, element_type = :vertex, itype = :non_unique)
        type = orient_type(nil, element_type)
        type.property!(name).create_index!(itype) if type
      end

      def drop_key_index(name, element_type = :vertex)
        in_pure_transaction do
          super
        end
      end

      private

      def in_pure_transaction
        if @in_pure_transaction
          yield
        else
          begin
            @in_pure_transaction = true
            transaction do
              orient_graph.rollback
              yield
            end
          ensure
            @in_pure_transaction = false
          end
        end
      end
    end
  end
end
