require 'pacer' unless defined? Pacer

lib_path = File.expand_path(File.join(File.dirname(__FILE__), '../lib'))
$:.unshift lib_path unless $:.any? { |path| path == lib_path }

require 'pacer-orient/version'

require Pacer::Orient::JAR

require 'pacer-orient/graph'

Pacer::FunctionResolver.clear_cache

module Pacer
  # Add 'static methods' to the Pacer namespace.
  class << self
    # Return a graph for the given path. Will create a graph if none exists at
    # that location.
    #
    # If the graph is opened from a path, it will be registered to be closed by
    # Ruby's at_exit callback, but if an already open graph is given, it will
    # not.
    def orient(url = nil, args = nil)
      if url.nil?
        url = "memory:#{ next_orient_name }"
      elsif url.is_a? String and url !~ /^(plocal|local|remote|memory):/
        url = "plocal:#{ url }"
      end
      if args
        username          = args.delete :username
        password          = args.delete :password
        transactional     = args.delete :transactional
        lightweight_edges = args.delete :lightweight_edges
        edge_classes      = args.delete :edge_classes
        vertex_classes    = args.delete :vertex_classes
      end
      if url.is_a? String
        open = proc do
          # TODO: can / should I cache connections? Is it essential to shut down Orient?
          factory = Pacer.open_graphs[[url, username]]
          unless factory
            factory =
              if username
                com.tinkerpop.blueprints.impls.orient.OrientGraphFactory.new url, username, password
              else
                com.tinkerpop.blueprints.impls.orient.OrientGraphFactory.new url
              end
            Pacer.open_graphs[[url, username]] = Pacer::Orient::FactoryContainer.new(factory)
          end
          if transactional == false
            graph = factory.getNoTx()
          else
            graph = factory.getTx()
          end
          graph.useLightweightEdges = lightweight_edges if lightweight_edges == false
          graph.useClassForEdgeLabel = edge_classes if edge_classes == false
          graph.useClassForVertexLabel = vertex_classes if vertex_classes == false
          #graph.setAutoStartTx false
          graph
        end
        shutdown = proc do |g|
          factory = Pacer.open_graphs.delete [url, username]
          factory.shutdown if factory
        end
        Orient::Graph.new(Pacer::YamlEncoder, open, shutdown)
      else
        # Don't register the new graph so that it won't be automatically closed.
        graph = url
        Orient::Graph.new Pacer::YamlEncoder, proc { graph }
      end
    end

    private

    def next_orient_name
      @next_orient_name ||= "orient000"
      @next_orient_name.succ!
    end
  end
end
