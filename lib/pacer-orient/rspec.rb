class RSpec::GraphRunner
  module Orient
    def all(usage_style = :read_write, indices = true, &block)
      super
      orient(usage_style, indices, &block)
    end

    def orient(usage_style = :read_write, indices = true, &block)
      for_graph('orient', usage_style, indices, true, orient_graph, orient_graph2, orient_graph_no_indices, block)
    end

    protected

    def orient_graph
      return @orient_graph if @orient_graph
      path1 = File.expand_path('/tmp/spec.orient')
      dir = Pathname.new(path1)
      dir.rmtree if dir.exist?
      @orient_graph = Pacer.orient(path1, lightweight_edges: false, edge_classes: false)
      p orient_graph: @orient_graph
      @orient_graph
    end

    def orient_graph2
      return @orient_graph2 if @orient_graph2
      path2 = File.expand_path('/tmp/spec.orient.2')
      dir = Pathname.new(path2)
      dir.rmtree if dir.exist?
      @orient_graph2 = Pacer.orient(path2, lightweight_edges: false, edge_classes: false)
    end

    def orient_graph_no_indices
      return @orient_graph_no_indices if @orient_graph_no_indices
      path3 = File.expand_path('/tmp/spec.orient.3')
      dir = Pathname.new(path3)
      dir.rmtree if dir.exist?
      @orient_graph_no_indices = Pacer.orient(path3, lightweight_edges: false, edge_classes: false)
    end
  end
end
