# frozen_string_literal: true

module GraphQR
  ##
  # This is an extension used on the `GraphQR::Fields::BaseField`.
  #
  # It is responsible for authorizing each field within a query.
  # It searches if the field is defined on the `permitted_fields` method of the policy
  class PermittedFieldsExtension < GraphQL::Schema::FieldExtension
    def resolve(object:, arguments:, context:)
      if authorized?(object, context)
        yield(object, arguments, nil)
      else
        on_unauthorized
      end
    end

    private

    def on_unauthorized
      raise GraphQL::ExecutionError, 'You are not authorized to perform this action' if field_required?
    end

    def field_required?
      !options[:null]
    end

    def authorized?(object, context)
      if root_type?(object, context)
        true
      else
        context[:policy_provider].permitted_field?(record: object.object, field_name: field_name)
      end
    end

    def field_name
      field.original_name
    end

    def root_type?(object, context)
      root_types = [context.schema.query.graphql_name, context.schema.mutation.graphql_name]

      root_types.include? object.class.graphql_name
    end
  end
end
