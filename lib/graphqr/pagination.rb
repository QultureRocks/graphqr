# frozen_string_literal: true

module GraphQR
  ##
  # TODO: add documentation
  module Pagination
    def pagination_type
      @pagination_type ||= begin
        conn_name = "#{graphql_name}Pagination"
        edge_type_class = edge_type

        Class.new(connection_type_class) do
          graphql_name(conn_name)
          edge_type(edge_type_class)

          field :page_info, Pagination::Types::PaginationPageInfoType, null: false,
                                                                       description: 'Information to aid in pagination.'
        end
      end
    end
  end
end
