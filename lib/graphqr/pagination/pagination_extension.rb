# frozen_string_literal: true

module GraphQR
  module Pagination
    ##
    # TODO: add documentation
    class PaginationExtension < GraphQL::Schema::FieldExtension
      DEFAULT_PAGINATION_ERROR = 'No paginator defined'

      def apply
        field.argument :per, 'Int', required: false, default_value: 25,
                                    description: 'The requested number of nodes for the page'
        field.argument :page, 'Int', required: false, default_value: 1,
                                     description: 'The requested page number'
      end

      # Remove pagination args before passing it to a user method
      def resolve(object:, arguments:, **_kwargs)
        next_args = arguments.dup
        next_args.delete(:per)
        next_args.delete(:page)
        yield(object, next_args)
      end

      def after_resolve(value:, arguments:, **_kwargs)
        raise GraphQL::ExecutionError, DEFAULT_PAGINATION_ERROR unless GraphQR.paginator.present?

        Resolvers::PagyResolver.new(value, items: arguments[:per], page: arguments[:page]) if GraphQR.use_pagy?
      end
    end
  end
end
