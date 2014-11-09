module Pacer
  module Orient
    class CachedTxDataWrapper
      attr_reader :created_v, :deleted_v, :changed_v, :created_e, :deleted_e, :changed_e, :entries

      def initialize(db, graph)
        w = TxDataWrapper.new(db, graph)
        @created_v = w.created_v
        @deleted_v = w.deleted_v
        @changed_v = w.changed_v
        @created_e = w.created_e
        @deleted_e = w.deleted_e
        @changed_e = w.changed_e
        @entries = w.entries
      end
    end

    class TxDataWrapper
      import com.orientechnologies.orient.core.db.record.ORecordOperation

      attr_reader :db, :v_base, :e_base, :graph, :blueprints_graph

      def initialize(db, graph)
        @db = db
        @graph = graph
        @blueprints_graph = graph.blueprints_graph
        @v_base = graph.orient_graph.getMetadata.getSchema.getClass("V")
        @e_base = graph.orient_graph.getMetadata.getSchema.getClass("E")
      end

      def created_v
        keep(ORecordOperation::CREATED, v_base) { |e| wrap_vertex e }
      end

      def deleted_v
        keep(ORecordOperation::DELETED, v_base) { |e| wrap_vertex e }
      end

      def changed_v
        keep(ORecordOperation::UPDATED, v_base) { |e| changes e, :vertex }.flatten
      end

      def created_e
        keep(ORecordOperation::CREATED, e_base) { |e| wrap_edge e }
      end

      def deleted_e
        keep(ORecordOperation::DELETED, e_base) { |e| wrap_edge e }
      end

      def changed_e
        keep(ORecordOperation::UPDATED, e_base) { |e| changes e, :edge }.flatten
      end

      def created_v_ids
        keep(ORecordOperation::CREATED, v_base) { |e| e.getIdentity }
      end

      def deleted_v_ids
        keep(ORecordOperation::DELETED, v_base) { |e| e.getIdentity }
      end

      def created_e_ids
        keep(ORecordOperation::CREATED, e_base) { |e| e.getIdentity }
      end

      def deleted_e_ids
        keep(ORecordOperation::DELETED, e_base) { |e| e.getIdentity }
      end

      def deleted?(e)
        entry = db.getTransaction.getRecordEntry e.element_id
        entry and entry.type == ORecordOperation::DELETED
      end

      def entries
        db.getTransaction.getCurrentRecordEntries
      end

      private

      # !!!!!!!!!!!!!!!!!!!!
      # !!!!!!!!!!!!!!!!!!!!
      # TODO: how do I deal with lightweight edges?
      # !!!!!!!!!!!!!!!!!!!!
      # !!!!!!!!!!!!!!!!!!!!

      def keep(op, klass)
        return unless entries
        entries.map do |e|
          if e.type == op
            sc = e.getRecord.getSchemaClass
            if sc
              if sc.isSubClassOf(klass)
                yield e.getRecord
              end
            else
              if klass == v_base
                yield e.getRecord
              end
            end
          end
        end.compact
      end

      def changes(doc, type)
        doc.getDirtyFields.map do |field|
          { element_type: type,
            id: doc.getIdentity,
            key: field,
            was: graph.decode_property(doc.getOriginalValue(field)),
            is: graph.decode_property(doc.field(field)) }
        end
      end

      def wrap_edge(e)
        Pacer::Wrappers::EdgeWrapper.new graph, blueprints_graph.getEdge(e)
      end

      def wrap_vertex(e)
        Pacer::Wrappers::VertexWrapper.new graph, blueprints_graph.getVertex(e)
      end
    end
  end
end
