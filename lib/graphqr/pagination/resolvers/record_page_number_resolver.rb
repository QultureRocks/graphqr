# frozen_string_literal: true

module GraphQR
  module Pagination
    module Resolvers
      ##
      # This is a resolver that receives the id of an object and returns the page number
      # in which the object is located.
      class RecordPageNumberResolver < ::GraphQL::Schema::Resolver
        INDEX_OFFSET = 1

        type Int, null: true

        argument :record_id, ID, required: true

        def resolve(record_id:)
          per_page = object.vars[:items]
          records_ids = object.ordered_record_ids_proc.call
          record_index = records_ids.find_index(record_id.to_i)

          return if per_page.zero? || records_ids.blank? || record_index.blank?

          record_position = (record_index + INDEX_OFFSET).to_f
          (record_position / per_page).ceil
        end
      end
    end
  end
end
