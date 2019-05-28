# frozen_string_literal: true

module GraphQR
  module ScopeItems
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
