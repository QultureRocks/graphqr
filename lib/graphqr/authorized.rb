# frozen_string_literal: true

module GraphQR
  module Authorized
    def authorized?(object, context)
      policy_provider = context[:policy_provider]

      super && policy_provider.allowed?(action: :show?, record: object)
    end
  end
end
