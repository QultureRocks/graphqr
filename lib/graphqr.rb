# frozen_string_literal: true

require 'graphql'
require 'graphqr/configuration'

##
# This module represents all the extensions we made to the graphql-ruby library
# it contains helpers and integrations we need to keep our workflow as simple as possible.
module GraphQR
  class << self
    def use_pagination
      GraphQR.config.use_pagination || true
    end

    def use_authorization
      GraphQR.config.use_authorization || true
    end

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
require 'graphqr/pagination/resolvers/record_page_number_resolver'
require 'graphqr/pagination/types/pagination_page_info_type'
require 'graphqr/pagination/pagination_extension'

begin
  require 'graphqr/pagination/resolvers/pagy_resolver'
rescue NameError
  Kernel.warn 'Pagy not found'
end

require 'graphqr/policies/authorize_graphql'
begin
  require 'graphqr/policies/pundit_provider'
rescue LoadError
  Kernel.warn 'Pundit not found'
end

require 'graphqr/apply_scopes'
require 'graphqr/authorized'
require 'graphqr/pagination'
require 'graphqr/permitted_fields_extension'
require 'graphqr/base_resolver'
require 'graphqr/base_resolvers'
require 'graphqr/query_field'
require 'graphqr/relation_fields'
require 'graphqr/scope_items'
require 'graphqr/version'
