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
      @orient_graph = Pacer.orient
    end

    def orient_graph2
      return @orient_graph2 if @orient_graph2
      @orient_graph2 = Pacer.orient
    end

    def orient_graph_no_indices
      return @orient_graph_no_indices if @orient_graph_no_indices
      @orient_graph_no_indices = Pacer.orient
    end
  end
end
