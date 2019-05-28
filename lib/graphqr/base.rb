# frozen_string_literal: true

module GraphQR
  ##
  # The Base module defines some helper methods that can be used once it is included
  # it also includes the basic libraries (Pundit and ApplyScopes)
  module Base
    include Pundit
    include GraphQR::ApplyScopes

    ##
    # This method is a wrapper around the Pundit authorize, receiving the same arguments.
    # The only difference is that it turns the Pundit::NotAuthorizedError into a GraphQL::ExecutionError
    #
    # ### Example:
    #
    # ```
    # authorize_graphql Contract, :index?
    # ```
    def authorize_graphql(record, action, policy_class: nil)
      args = { record: record, action: action, policy_class: policy_class }
      raise GraphQL::ExecutionError, 'You are not authorized to perform this action' unless policy_provider.allowed?(args)
    end

    ##
    # This is a helper method to get the current company from the context
    def current_company
      context[:current_company]
    end

    ##
    # This is a helper method to get the current contract from the context
    def current_contract
      context[:current_contract]
    end

    ##
    # This is a helper method to get the pundit user from the context
    # The pundit user is needed for Pundit usage
    def pundit_user
      context[:policy_context]
    end

    ##
    # This is a helper method to get the policy provider from the context
    def policy_provider
      context[:policy_provider]
    end
  end
end
