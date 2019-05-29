# frozen_string_literal: true

module GraphQR
  ##
  # This module represents all the extensions we made to the basic GraphQL::Schema::Field class
  # it contains helpers and integrations we need to keep our workflow as simple as possible.
  module Fields
    ##
    # The BaseField class rewrites the field initialization, adding some options that could be helpful:
    #
    # ## paginate
    # This option defines if the field should use the PaginationExtension
    #
    # ### Example:
    # ```
    # field :users, [UserType], paginate: true
    # ```
    class BaseField < GraphQL::Schema::Field
      def initialize(*args, paginate: false, **kwargs, &block)
        super(*args, **kwargs, &block)
        extension(Pagination::PaginationExtension) if paginate && GraphQR.use_pagination
        extension(PermittedFieldsExtension, null: kwargs[:null]) if GraphQR.use_authorization
      end
    end
  end
end
