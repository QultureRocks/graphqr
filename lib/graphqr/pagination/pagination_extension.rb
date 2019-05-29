# frozen_string_literal: true

module GraphQR
  module Pagination
    ##
    # The PaginationExtension is used on the `GraphQR::Fields::BaseField`.
    #
    # It adds the `per` and `page` arguments to the paginated field and uses the selected paginator resolver to add
    # `nodes`, `edges` and `page_info` on the response
    class PaginationExtension < GraphQL::Schema::FieldExtension
      NO_PAGINATOR_ERROR = 'No paginator defined'
      INVALID_PAGINATOR_ERROR = 'Invalid paginator'

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
        raise GraphQL::ExecutionError, NO_PAGINATOR_ERROR unless GraphQR.paginator.present?

        call_resolver(value, arguments)
      end

      def call_resolver(value, arguments)
        case GraphQR.paginator
        when :pagy
          Resolvers::PagyResolver.new(value, items: arguments[:per], page: arguments[:page])
        else
          raise GraphQL::ExecutionError, INVALID_PAGINATOR_ERROR
        end
      end
    end
  end
end
