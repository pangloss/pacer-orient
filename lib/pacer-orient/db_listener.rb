module Pacer
  module Orient
    import com.orientechnologies.orient.core.db.ODatabaseListener

    class DbListener
      include ODatabaseListener

      attr_reader :graph, :ident

      def initialize(graph)
        @ident = :"listener#{rand}"
        @graph = graph
      end

      def data=(x)
        Thread.current[ident] = x
      end

      def data
        Thread.current[ident]
      end

      def onCreate(db)
      end

      def onDelete(db)
      end

      def onOpen(db)
      end

      def onBeforeTxBegin(db)
      end

      def onBeforeTxRollback(db)
      end

      def onAfterTxRollback(db)
      end

      def onBeforeTxCommit(db)
      end

      def onAfterTxCommit(db)
      end

      def onClose(db)
      end

      def onCorruptionRepairDatabase(db, iReason, iWhatWillbeFixed)
        return false
      end
    end

    class DbCommitListener < DbListener
      attr_reader :on_commit

      def initialize(graph, on_commit)
        @on_commit = on_commit
        super graph
      end

      def onBeforeTxCommit(db)
        self.data = CachedTxDataWrapper.new db, graph
      rescue Exception => e
        puts "Exception: #{ e.message }"
        pp e.backtrace
        nil
      end

      def onAfterTxCommit(db)
        on_commit.call self.data
      rescue Exception => e
        puts "Exception: #{ e.message }"
        pp e.backtrace
        nil
      ensure
        self.data = nil
      end
    end
  end
end

