# frozen_string_literal: true

# rubocop:disable Metrics/ParameterLists

module GraphQR
  module QueryField
    def query_field(field_name, active_record_class, type_class:, scope_class: nil, **kwargs, &block)
      is_collection = active_record_class.is_a? Array
      if is_collection
        active_record_class = active_record_class.first
        resolver = collection(active_record_class, type_class, scope_class)
      else
        resolver = resource(active_record_class, type_class)
      end

      field(field_name, paginate: is_collection, resolver: resolver, **kwargs, &block)
    end

    private

    def collection(active_record_class, type_class, scope_class)
      Class.new(::BaseResolver) do
        class_attribute :active_record_class
        self.active_record_class = active_record_class

        type type_class.pagination_type, null: false

        argument :filter, scope_class, required: false

        def resolve(filter: {})
          authorize_graphql active_record_class, :index?

          collection = apply_scopes(active_record_class, filter)
          context[:policy_provider].authorized_records(records: collection)
        end
      end
    end

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
  end
end
# rubocop:enable Metrics/ParameterLists
