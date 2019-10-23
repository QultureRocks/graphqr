# frozen_string_literal: true

module GraphQR
  ##
  # This is the base class for all resolvers defined by the `GraphQR` gem.
  # It includes authorization and scoping extensions defined by the gem.
  class BaseResolver < GraphQL::Schema::Resolver

    include GraphQR::ApplyScopes
    include GraphQR::Policies::AuthorizeGraphQL
  end
end
