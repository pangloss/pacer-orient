module Pacer
  module Orient
    class TxDataWrapper
      import com.orientechnologies.orient.core.db.record.ORecordOperation

      attr_reader :tx, :entries, :v_base, :e_base, :graph, :blueprints_graph

      def initialize(odb, graph)
        @graph = graph
        @blueprints_graph = graph.blueprints_graph
        @tx = odb.getTransaction
        @entries = tx.getAllRecordEntries
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
        entry = tx.getRecordEntry e.element_id
        entry and entry.type == ORecordOperation::DELETED
      end

      private

      # !!!!!!!!!!!!!!!!!!!!
      # !!!!!!!!!!!!!!!!!!!!
      # TODO: how do I deal with lightweight edges?
      # !!!!!!!!!!!!!!!!!!!!
      # !!!!!!!!!!!!!!!!!!!!

      def keep(op, klass)
        entries.map do |e|
          if e.type == op and e.getSchemaClass.isSubClassOf(klass)
            yield e.getRecord
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
        Pacer::Wrappers::VertexWrapper.new graph, OrientVertex.new(blueprints_graph, e)
      end

      def wrap_vertex(e)
        Pacer::Wrappers::VertexWrapper.new graph, OrientVertex.new(blueprints_graph, e)
      end
    end
  end
end
