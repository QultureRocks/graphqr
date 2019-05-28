# frozen_string_literal: true

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

require 'graphqr/fields/base_field'

require 'graphqr/pagination/types/pagination_page_info_type'
require 'graphqr/pagination/pagination_extension'
require 'graphqr/pagination/pagination_resolver'

require 'graphqr/apply_scopes'
require 'graphqr/authorized'
require 'graphqr/base'
require 'graphqr/pagination'
require 'graphqr/permitted_fields_extension'
require 'graphqr/query_field'
require 'graphqr/scope_items'
require 'graphqr/version'
