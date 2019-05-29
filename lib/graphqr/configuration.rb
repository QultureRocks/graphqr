# frozen_string_literal: true

module GraphQR # rubocop:disable Style/Documentation
  ##
  # TODO: add documentation
  class Configuration
    def configure
      yield self
    end

    ##
    # Returns the selected paginator.
    # If no paginator is selected, it tries to find the one used
    def paginator
      if instance_variable_defined? :@paginator
        @paginator
      else
        set_paginator
      end
    end

    ##
    # Sets the preferred paginator
    # TODO: support more than Pagy
    def paginator=(paginator)
      case paginator.to_sym
      when :pagy
        use_pagy
      else
        raise StandardError, "Unknown paginator: #{paginator}"
      end
    end

    ##
    # Returns the selected policy_provider.
    # If no policy_provider is selected, it tries to find the one used
    def policy_provider
      if instance_variable_defined? :@policy_provider
        @policy_provider
      else
        set_policy_provider
      end
    end

    ##
    # Sets the preferred policy_provider
    # TODO: support CanCan
    def policy_provider=(policy_provider)
      case policy_provider.to_sym
      when :pundit
        use_pundit
      else
        raise StandardError, "Unknown policy_provider: #{policy_provider}"
      end
    end

    private

    def set_paginator
      use_pagy if defined?(Pagy)
    end

    def use_pagy
      @paginator = :pagy
    end

    def set_policy_provider
      use_pundit if defined?(Pundit)
    end

    def use_pundit
      @policy_provider = :pundit
    end
  end

  class << self
    def configure
      yield config
    end

    def config
      @config ||= Configuration.new # rubocop:disable ThreadSafety/InstanceVariableInClassMethod
    end
    alias configuration config
  end
end
