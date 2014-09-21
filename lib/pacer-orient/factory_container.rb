module Pacer::Orient
  class FactoryContainer
    attr_reader :factory, :url
    attr_accessor :encoder, :transactional, :lightweight_edges, :edge_classes, :vertex_classes

    def initialize(f, url, args)
      @factory = f
      @url = url
      Pacer.open_graphs[url] = self
      if args
        @transactional     = args[:transactional]
        @lightweight_edges = args[:lightweight_edges]
        @edge_classes      = args[:edge_classes]
        @vertex_classes    = args[:vertex_classes]
        self.stay_open     = args[:stay_open]
        @encoder = args.fetch :encoder, Encoder
        min = args[:pool_min]
        max = args[:pool_max]
        setupPool min, max if min and max
      end
    end

    def setupPool(min, max)
      factory.setupPool min, max
    end

    def stay_open=(b)
      #factory.setLeaveGraphsOpen b
    end

    def stay_open
      #factory.getLeaveGraphsOpen
    end

    def graph
      Graph.new encoder, proc { get }
    end

    def get
      if transactional == false
        getNoTx
      else
        getTx
      end
    end

    def getTx
      configure factory.getTx
    end

    def getNoTx
      configure factory.getNoTx
    end

    # Pacer calls shutdown on all cached graphs when it exits. Orient caches this factory.
    def shutdown
      factory.close
      Pacer.open_graphs.delete url
    end

    private

    def configure(graph)
      graph.setUseLightweightEdges lightweight_edges if lightweight_edges == false
      graph.setUseClassForEdgeLabel edge_classes if edge_classes == false
      graph.setUseClassForVertexLabel vertex_classes if vertex_classes == false
      graph.setAutoStartTx false
      graph.setRequireTransaction true
      graph
    end
  end
end
