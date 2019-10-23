# frozen_string_literal: true

module GraphQR
  ##
  # The `BaseResolvers` module defines methods used by other extensions to define resolver classes.
  # All resolvers defined by this module's methods inherit from `GraphQR::BaseResolver`.
  module BaseResolvers
    ##
    # The method defines and returns a resolver class meant for resolving a paginated ActiveRecordRelation.
    # The returned class implements authorization, running the `PolicyProvider`'s' `index?` action
    # and `authorized_records` scope.
    #
    # The defined resolver does not implement `#unscoped_collection`. Define it before adding the query to the schema**
    #
    # ### Params:
    #
    # +type_class+: the `GraphQL::Schema::Object` of the ActiveRecordRelation
    #
    # +scope_class+: a `GraphQL::Schema::InputObject` which defines arguments to be used by `ApplyScopes`
    # #### Example:
    #   ```
    #   class ObjectScope < GraphQL::Schema::InputObject
    #     argument :with_relation_id, ID, required: false
    #     ...
    #   end
    #   ```
    #
    # ### Example:
    #
    # ```
    # base_collection_resolver(ObjectType, ObjectScope)
    # ```
    def base_collection_resolver(type_class, scope_class)
      Class.new(GraphQR::BaseResolver) do
        type type_class.pagination_type, null: false

        argument :filter, scope_class, required: false if scope_class.present?

        def resolve(filter: {})
          authorize_graphql unscoped_collection, :index?

          collection = apply_scopes(unscoped_collection, filter)
          context[:policy_provider].authorized_records(records: collection)
        end

        def unscoped_collection
          raise NotImplementedError
        end
      end
    end

    ##
    # The method defines and returns a resolver class meant for resolving a single ActiveRecord
    # The returned class implements authorization, running the `PolicyProvider`'s' `show`
    #
    # The defined resolver does not implement `#record`. Define it before adding the query to the schema**
    #
    # ### Params:
    #
    # +type_class+: the `GraphQL::Schema::Object` of the ActiveRecord
    #
    # ### Example:
    #
    # ```
    # base_resource_resolver(ObjectType)
    # ```
    def base_resource_resolver(type_class)
      Class.new(GraphQR::BaseResolver) do
        type type_class, null: false

        def resolve
          context[:policy_provider].allowed?(action: :show?, record: record)

          record
        end

        def record
          raise NotImplementedError
        end
      end
    end
  end
end
