# frozen_string_literal: true

module GraphQR
  ##
  # @TODO doc
  class BaseResolver < GraphQL::Schema::Resolver
    ##
    # @TODO doc
    include GraphQR::ApplyScopes
    include GraphQR::Policies::AuthorizeGraphQL
  end
end
