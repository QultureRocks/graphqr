# frozen_string_literal: true

module GraphQR
  ##
  # This extension adds the `query_field` method.
  # A helper to create simple queries faster and easier
  #
  # To use this extension, add `extend Graphql::QueryField` on your `QueryType`
  module QueryField
    # rubocop:disable Metrics/ParameterLists

    ##
    # The `query_field` method is a helper to create fields and resolver without effort.
    #
    # ### Arguments
    #
    # +field_name+ _(required)_: the GraphQL query name
    #
    # +active_record_class+ _(required)_: the model ActiveRecord class.
    # It can be represented as an array if you want it to return a collection
    #
    # +type_class+ _(required)_:  The GraphQL type class
    #
    # +scope_class+: A specific InputType that contains the possible scopes that can be applied to your collection.
    # Similar to the [has_scope](https://github.com/plataformatec/has_scope/) gem.
    # _This argument is required for collection fields._
    #
    # ### Examples
    # ```
    # query_type :user, User, type_class: UserType
    # query_type :users, [User], type_class: UserType, scope_class: UserScopeInput
    # ```
    #
    # ### Collention fields
    #
    # Collection fields are always paginated using the configured `paginator`
    # Its resolver will look for the `index?` method on the model Policy.
    # It'll have the optional `filter` argument with `scope_class` type
    #
    # ### Single fields
    #
    # Single fields have the required `id` argument to find the exact record searched.
    # Its resolver will look for the `show?` method on the model Policy.
    def query_field(field_name, active_record_class, type_class:, scope_class: nil, **kwargs, &block)
      is_collection = active_record_class.is_a? Array
      if is_collection
        active_record_class = active_record_class.first
        resolver = query_collection(active_record_class, type_class, scope_class)
      else
        resolver = resource(active_record_class, type_class)
      end

      field(field_name, paginate: is_collection, resolver: resolver, **kwargs, &block)
    end

    #
    # The `has_many_field` method is a variation of the collection query_field.
    #
    # It is to be used the same way, but it requires the #object attribute to be present
    # during the field resolve execution. This object must have a :has_many relation with
    # the active_record veing resolved.
    #
    # The query will be performed within the objects children instead of the active record class.
    def has_many_field(field_name, active_record_class, type_class:, scope_class: nil, **kwargs, &block)
      active_record_class = active_record_class.first
      resolver = has_many_collection(field_name, active_record_class, type_class, scope_class)

      field(field_name, paginate: true, resolver: resolver, **kwargs, &block)
    end
    # rubocop:enable Metrics/ParameterLists

    private

    def resource(active_record_class, type_class)
      Class.new(::BaseResolver) do
        class_attribute :active_record_class
        self.active_record_class = active_record_class

        type type_class, null: false

        argument :id, 'ID', required: true

        def resolve(id:)
          record = self.class.active_record_class.find(id)

          context[:policy_provider].allowed?(action: :show?, record: record)

          record
        end
      end
    end

    def collection(active_record_class, type_class, scope_class)
      Class.new(::BaseResolver) do
        class_attribute :active_record_class
        self.active_record_class = active_record_class

        type type_class.pagination_type, null: false

        argument :filter, scope_class, required: false

        def resolve(filter: {})
          authorize_graphql active_record_class, :index?

          scoped_collection = apply_scopes(collection, filter)
          context[:policy_provider].authorized_records(records: scoped_collection)
        end
      end
    end

    def query_collection(active_record_class, type_class, scope_class)
      collection(active_record_class, type_class, scope_class).class_eval do
        def collection
          active_record_class
        end
      end
    end

    def has_many_collection(field_name, active_record_class, type_class, scope_class)
      collection(active_record_class, type_class, scope_class).class_eval do
        class_attribute :field_name
        self.field_name = field_name

        def collection
          object.send(field_name)
        end
      end
    end
  end
end
