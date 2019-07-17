# frozen_string_literal: true

module GraphQR
  ##
  # @TODO doc
  module RelationFields
    ##
    # @TODO doc
    # rubocop:disable Naming/PredicateName
    include GraphQR::BaseResolvers

    def has_many(field_name, type_class, scope_class: nil, **kwargs, &block)
      type_class = type_class.first

      resolver = has_many_resolver(field_name, type_class, scope_class)

      field(field_name, paginate: true, resolver: resolver, **kwargs, &block)
    end

    private

    def has_many_resolver(collection_name, type_class, scope_class)
      resolver = base_collection_resolver(type_class, scope_class)
      resolver.define_method(:unscoped_collection) { @unscoped_collection ||= object.send(collection_name) }
      resolver
    end
    # rubocop:enable Naming/PredicateName
  end
end
