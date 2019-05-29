# frozen_string_literal: true

require 'graphql'
require 'graphqr/configuration'

##
# This module represents all the extensions we made to the graphql-ruby library
# it contains helpers and integrations we need to keep our workflow as simple as possible.
module GraphQR
  class << self
    def paginator
      GraphQR.config.paginator
    end

    def policy_provider
      GraphQR.config.policy_provider
    end

    def use_pagy?
      paginator == :pagy
    end

    def use_pundit?
      policy_provider == :pundit
    end
  end
end

require 'graphqr/hooks'

require 'graphqr/fields/base_field'
require 'graphqr/pagination/types/pagination_page_info_type'
require 'graphqr/pagination/pagination_extension'

begin
  require 'graphqr/pagination/resolvers/pagy_resolver'
rescue NameError
  Kernel.warn 'Pagy not found'
end

begin
  require 'graphqr/policies/pundit_provider'
rescue LoadError
  Kernel.warn 'Pundit not found'
end

require 'graphqr/apply_scopes'
require 'graphqr/authorized'
require 'graphqr/base'
require 'graphqr/pagination'
require 'graphqr/permitted_fields_extension'
require 'graphqr/query_field'
require 'graphqr/scope_items'
require 'graphqr/version'
