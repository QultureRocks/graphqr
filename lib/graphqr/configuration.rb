# frozen_string_literal: true

module GraphQR # rubocop:disable Style/Documentation
  ##
  # TODO: add documentation
  class Configuration
    def configure
      yield self
    end

    # Returns the selected paginator
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

    private

    def set_paginator
      use_pagy if defined?(Pagy)
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
