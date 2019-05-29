# frozen_string_literal: true

module GraphQR
  ##
  # This module is the authorization extension created with our PolicyProvider.
  #
  # To use it add `extend GraphQR::Authorized` on the `GraphQL::Schema::Object` you want it,
  # or add it on your `BaseObject`
  module Authorized
    ##
    # The `authorized? `method always runs before resolving an object.
    #
    # Our implementation adds a check on the `show?` method from the record Policy.
    def authorized?(object, context)
      policy_provider = context[:policy_provider]

      super && policy_provider.allowed?(action: :show?, record: object)
    end
  end
end
