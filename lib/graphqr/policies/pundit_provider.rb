# frozen_string_literal: true

require 'pundit'

module GraphQR
  module Policies
    ##
    # This is a wrapper around Pundit provided to keep all PolicyProviders with the same methods.
    #
    # If you want to use the Pundit integration with our extensions you should pass:
    #
    # ```
    # {
    #   policy_provider: GraphQR::Policies::PunditProvider.new(policy_context: pundit_user)
    # }
    # ```
    #
    # To the Schema context.
    class PunditProvider
      attr_reader :policy_context

      def initialize(policy_context:)
        @policy_context = policy_context
      end

      def allowed?(action:, record:, policy_class: nil)
        policy = policy_for(record: record, policy_class: policy_class)

        policy.apply(action)
      end

      def authorized_records(records:)
        Pundit.policy_scope(policy_context, records)
      end

      def permitted_field?(record:, field_name:)
        policy = policy_for(record: record)

        policy.permitted_fields.include?(field_name)
      end

      private

      def policy_for(record:, policy_class: nil)
        policy_class ||= policy_class_for(record: record)
        policy_class.new(policy_context, record)
      end

      def policy_class_for(record:)
        Pundit::PolicyFinder.new(record).policy!
      end
    end
  end
end
