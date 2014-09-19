module Pacer
  module Filter
    module SqlFilter
      attr_accessor :sql, :select, :orient_type, :where, :query_args, :order_by, :limit, :offset, :timeout, :parallel

      protected

      def orient_type_name
        t = graph.orient_type(orient_type, element_type)
        if t
          t.name
        else
          fail Pacer::ClientError.new "Unknown orient type for #{ element_type }: #{ orient_type }"
        end
      end

      def query
        if sql
          s = ""
          s << sql
        else
          s = "SELECT "
          case select
          when String
            s << select
          when Array
            s << select.join(", ")
          end
          s << " FROM #{ orient_type } WHERE "
          s << where
          s << "ORDER_BY " if order_by
          case order_by
          when String
            s << order_by
          when Array
            s << order_by.join(", ")
          end
        end
        s << " SKIP #{ offset }" if offset
        s << " LIMIT #{ limit }" if limit
        s << " TIMEOUT #{ timeout }" if timeout
        s << " PARALLEL" if parallel
        s
      end

      def source_iterator
        graph.sql_command(query, query_args).iterator
      end

      def inspect_string
        "SQL '#{query}' #{query_args}"
      end
    end
  end
end
