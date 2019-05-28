# frozen_string_literal: true

module GraphQR
  module Pagination
    module Types
      class PaginationPageInfoType < GraphQL::Schema::Object
        description 'Information about pagination in a connection.'

        field :total_count, Int, null: false, method: :count, description: 'The collection count'
        field :page, Int, null: false, description: 'The current page number'
        field :nodes_count, Int, null: false, method: :items, description: 'The actual number of nodes in the current non-empty page'
        field :pages_count, Int, null: false, method: :pages, description: 'The number of total pages in the collection'
        field :previous_page, Int, null: true, method: :prev, description: 'The previous page number or nil if there is no previous page'
        field :next_page, Int, null: true, method: :next, description: 'The previous page number or nil if there is no previous page'
      end
    end
  end
end
