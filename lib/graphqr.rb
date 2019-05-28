# frozen_string_literal: true

require 'graphqr/version'

##
# This module represents all the extensions we made to the graphql-ruby library
# it contains helpers and integrations we need to keep our workflow as simple as possible.
module GraphQR
  class << self
    # Switches GraphQR on or off
    def enabled=(value)
      GraphQR.config.enabled = value
    end

    # Returns if GraphQR is turned on
    def enabled?
      GraphQR.config.enabled.present?
    end
  end
end
