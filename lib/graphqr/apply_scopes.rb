# frozen_string_literal: true

module GraphQR
  ##
  # The ApplyScopes module defines a way of applying model scopes in the GraphQL universe
  # it is based on the [has_scope](https://github.com/plataformatec/has_scope/) gem, but simplified for more basic usage
  module ApplyScopes
    ##
    # This method is a parallel to the one offerend by the `has_scope` gem.
    # A big difference in this case is the necessity of the second parameter (normally it only takes one).
    #
    # ### Params:
    #
    # +target+: the ActiveRecordRelation that will be filtered using scopes
    #
    # +scopes+: a hash of scopes and their values, those only accept Array, String, Integer or Boolean types.
    # **Hash scopes are not yet supported**
    #
    # ### Example:
    #
    # ```
    # apply_scopes(User, { with_id: [1,2,3], order_by_name: true} )
    # ```
    def apply_scopes(target, scopes)
      parsed_scopes = parse_scopes(scopes.to_h)

      parsed_scopes.each do |scope, value|
        target = call_scope(target, scope, value)
      end

      target
    end

    private

    ##
    # Parses the scope hash, removing scopes with a `nil` or `false` value
    def parse_scopes(scopes)
      scopes.inject({}) do |acc, option|
        option.last.present? ? acc.merge(option.first => option.last) : acc
      end
    end

    ##
    # Calls the scope with the correct parametes (none if its a boolean type)
    def call_scope(target, scope, value)
      if boolean?(value)
        target.send(scope)
      else
        target.send(scope, value)
      end
    end

    ##
    # Checks whether the value is a Boolean checking its class
    def boolean?(value)
      value.class == TrueClass || value.class == FalseClass
    end
  end
end
