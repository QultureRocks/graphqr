# frozen_string_literal: true

module GraphQR
  module Policies
    ##
    # The AuthorizeGraphQL module defines a way of running the PolicyProvider authorization with a specific action
    module AuthorizeGraphQL
      DEFAULT_AUTHORIZATION_ERROR = 'You are not authorized to perform this action'

      ##
      # This method is a wrapper around the Pundit authorize, receiving the same arguments.
      # The only difference is that it turns the Pundit::NotAuthorizedError into a GraphQL::ExecutionError
      #
      # ### Example:
      #
      # ```
      # authorize_graphql User, :index?
      # ```
      def authorize_graphql(record, action, policy_class: nil)
        args = { record: record, action: action, policy_class: policy_class }
        raise GraphQL::ExecutionError, DEFAULT_AUTHORIZATION_ERROR unless policy_provider.allowed?(args)
      end

      def policy_provider
        context[:policy_provider]
      end
    end
  end
end
