# frozen_string_literal: true

module GraphQR
  ##
  # This extension adds the `query_field` method.
  # A helper to create simple queries faster and easier
  #
  # To use this extension, add `extend Graphql::QueryField` on your `QueryType`
  #
  module QueryField
    include BaseResolvers
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
    #
    # rubocop:disable Metrics/ParameterLists
    def query_field(field_name, active_record_class, type_class:, scope_class: nil, **kwargs, &block)
      is_collection = active_record_class.is_a? Array
      if is_collection
        active_record_class = active_record_class.first
        resolver = collection_resolver(active_record_class, type_class, scope_class)
      else
        resolver = resource_resolver(active_record_class, type_class)
      end

      field(field_name, paginate: is_collection, resolver: resolver, **kwargs, &block)
    end
    # rubocop:enable Metrics/ParameterLists

    private

    def collection_resolver(active_record_class, type_class, scope_class)
      resolver = base_collection_resolver(type_class, scope_class)
      resolver.define_method(:unscoped_collection) { @unscoped_collection ||= active_record_class }
      resolver
    end

    def resource_resolver(active_record_class, type_class)
      Class.new(base_resource_resolver(type_class)) do
        class_attribute :active_record_class
        self.active_record_class = active_record_class

        argument :id, 'ID', required: true

        def resolve(id:)
          @id = id
          super()
        end

        def record
          @record ||= active_record_class.find(@id)
        end
      end
    end
  end
end
