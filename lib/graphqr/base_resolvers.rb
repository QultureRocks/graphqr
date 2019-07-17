# frozen_string_literal: true

module GraphQR
  ##
  # @TODO doc
  module BaseResolvers
    ##
    # @TODO doc
    def base_collection_resolver(type_class, scope_class)
      Class.new(::BaseResolver) do
        type type_class.pagination_type, null: false

        argument :filter, scope_class, required: false if scope_class.present?

        def resolve(filter: {})
          authorize_graphql unscoped_collection, :index?

          collection = apply_scopes(unscoped_collection, filter)
          context[:policy_provider].authorized_records(records: collection)
        end

        def unscoped_collection; end
      end
    end

    def base_resource_resolver(type_class)
      Class.new(::BaseResolver) do
        type type_class, null: false

        def resolve
          context[:policy_provider].allowed?(action: :show?, record: record)

          record
        end

        def record; end
      end
    end
  end
end
