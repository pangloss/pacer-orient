require 'pacer' unless defined? Pacer

java.lang.System.setProperty("java.awt.headless", "true") unless ENV['PACER_ORIENT_HEAD']

lib_path = File.expand_path(File.join(File.dirname(__FILE__), '../lib'))
$:.unshift lib_path unless $:.any? { |path| path == lib_path }

require 'pacer-orient/version'

require 'lock_jar'
LockJar.lock(File.join(File.dirname(__FILE__), "..", "Jarfile"))
LockJar.load

require 'pacer-orient/graph'
require 'pacer-orient/tx_data_wrapper'

Pacer::FunctionResolver.clear_cache

module Pacer
  # Add 'static methods' to the Pacer namespace.
  class << self
    def orient_factory(url = nil, args = {})
      if url.nil?
        url = "memory:#{ next_orient_name }"
      elsif url.is_a? String and url !~ /^(plocal|local|remote|memory):/
        url = "plocal:#{ url }"
      end
      if url
        factory = Pacer.open_graphs[url]
        if factory
          factory
        else
          if args
            username = args[:username]
            password = args[:password]
          end
          factory =
            if username
              com.tinkerpop.blueprints.impls.orient.OrientGraphFactory.new url, username, password
            else
              com.tinkerpop.blueprints.impls.orient.OrientGraphFactory.new url
            end
          Pacer::Orient::FactoryContainer.new(factory, url, args)
        end
      end
    end

    # Return a graph for the given path. Will create a graph if none exists at
    # that location.
    #
    # If the graph is opened from a path, it will be registered to be closed by
    # Ruby's at_exit callback, but if an already open graph is given, it will
    # not.
    def orient(url = nil, args = nil)
      if url.is_a? Pacer::Graph
        # Don't register the new graph so that it won't be automatically closed.
        Orient::Graph.new Pacer::Orient::Encoder, proc { url }
      else
        open = proc do
          orient_factory(url, args).get
        end
        shutdown = proc do |g|
          factory = Pacer.open_graphs.delete url
          factory.shutdown if factory
        end
        Orient::Graph.new(Pacer::Orient::Encoder, open, shutdown)
      end
    end

    private

    def next_orient_name
      @next_orient_name ||= "orient000"
      @next_orient_name.succ!
    end
  end
end
