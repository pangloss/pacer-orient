module Pacer
  module Orient
    import com.orientechnologies.orient.core.db.ODatabaseListener

    class DbListener
      include ODatabaseListener

      attr_reader :graph

      def initialize(graph)
        # TDOO: use graph factory?
        @graph = graph
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
        data = TxDataWrapper.new db, graph
        pp transaction: { getAllRecordEntries: data.entries,
                          length: data.entries.length,
                          contents: data.entries.to_a }
        pp created_v: data.created_v
        pp created_e: data.created_e
        pp changed_v: data.changed_v
        pp changed_e: data.changed_e
        pp deleted_v: data.deleted_v
        pp deleted_e: data.deleted_e

      end

      def onAfterTxCommit(db)
      end

      def onClose(db)
      end

      def onCorruptionRepairDatabase(db, iReason, iWhatWillbeFixed)
        return false
      end
    end

  end
end

