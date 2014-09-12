require 'set'

module Pacer
  module Orient
    class Graph < PacerGraph
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
