# frozen_string_literal: true

module GraphQR
  ##
  # This extension adds the PolicyProvider scope to the fields.
  # When using the extension, ActiveRecord::Relation fields will be scoped.
  #
  # To use this extension add `extend GraphQR::ScopeItems` on the Objects you want, or in your `BaseObject`
  module ScopeItems
    ##
    # The method checks whether the items are a ActiveRecord::Relationor not.
    # If they are, it runs the PolicyProvider `authorized_records` scope.
    def scope_items(items, context)
      if scopable_items?(items)
        context[:policy_provider].authorized_records(records: items)
      else
        items
      end
    end

    private

    def scopable_items?(items)
      items.is_a? ActiveRecord::Relation
    end
  end
end
