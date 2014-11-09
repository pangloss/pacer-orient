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
        self.data = d = CachedTxDataWrapper.new db, graph
        #on_commit.call d
        pp transaction: { getAllRecordEntries: d.entries,
                          length: d.entries.length,
                          contents: d.entries.to_a }
        pp created_v: d.created_v
        pp created_e: d.created_e
        pp changed_v: d.changed_v
        pp changed_e: d.changed_e
        pp deleted_v: d.deleted_v
        pp deleted_e: d.deleted_e
      rescue Exception => e
        puts "Exception: #{ e.message }"
        pp e.backtrace
        nil
      end

      def onAfterTxCommit(db)
        puts "-----------------------------------------------------------"
        d = self.data
        pp created_v: d.created_v
        pp created_e: d.created_e
        pp changed_v: d.changed_v
        pp changed_e: d.changed_e
        pp deleted_v: d.deleted_v
        pp deleted_e: d.deleted_e
      rescue Exception => e
        puts "Exception: #{ e.message }"
        pp e.backtrace
        nil
      end
    end
  end
end

