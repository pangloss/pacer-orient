require 'set'

module Pacer
  module Orient
    class Graph < PacerGraph
      import com.orientechnologies.orient.core.sql.OCommandSQL

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

      def sql(extensions, sql, *args)
        if extensions.is_a? String
          args = args.unshift sql if sql
          sql = extensions
        end
        raw_sql(sql, *args).iterator.to_route(based_on: self.v(extensions))
      end

      def sql_e(extensions, sql, *args)
        if extensions.is_a? String
          args = args.unshift sql if sql
          sql = extensions
        end
        raw_sql(sql, *args).iterator.to_route(based_on: self.e(extensions))
      end

      def sql_command(sql, *args)
        raw_sql(sql, *args).first
      end

      private

      def raw_sql(sql, *args)
        blueprints_graph.command(OCommandSQL.new(sql)).execute(*args)
      end
    end

    class FactoryContainer
      attr_reader :factory

      def initialize(f)
        @factory = f
      end

      def get
        factory.get
      end

      # Pacer calls shutdown on all cached graphs when it exits. Orient caches this factory.
      def shutdown
        factory.close
      end
    end
  end
end
