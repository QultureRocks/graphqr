# frozen_string_literal: true

module GraphQR
  module Pagination
    module Resolvers
      ##
      # This is a resolver that uses `Pagy::Backend` and maps it to the GraphQL pagination structure.
      class PagyResolver
        include Pagy::Backend

        def initialize(records, arguments)
          @records = records
          @arguments = arguments

          @pagy, paginated_records = pagy(records, arguments)
          @paginated_records = paginated_records.to_a
        end

        def cursor_from_node(item)
          item.to_global_id.to_s
        end

        def edge_nodes
          @paginated_records
        end

        def nodes
          @paginated_records
        end

        def edges
          @paginated_records
        end

        def page_info
          @pagy
        end
      end
    end
  end
end
