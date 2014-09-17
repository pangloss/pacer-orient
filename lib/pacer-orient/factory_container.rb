module Pacer::Orient
  class FactoryContainer
    attr_reader :factory

    def initialize(f)
      @factory = f
    end

    def get
      factory.get
    end

    def getTx
      factory.getTx
    end

    def getNoTx
      factory.getNoTx
    end

    # Pacer calls shutdown on all cached graphs when it exits. Orient caches this factory.
    def shutdown
      factory.close
    end
  end
end
