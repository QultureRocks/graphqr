# frozen_string_literal: true

module GraphQR
  ##
  # This module represents all the extensions we made to the basic GraphQL::Schema::Field class
  # it contains helpers and integrations we need to keep our workflow as simple as possible.
  #
  # Any structural modification that could be extracted of our codebase should be in this module
  # maybe it will someday become a gem, who knows.
  module Fields
    ##
    # The BaseField class rewrites the field initialization, adding some options that could be helpful:
    #
    # ## show
    # Works like the `if` parameter on the Serializers.  It receives a Proc that receives (object, args, context)
    # as parameters or a symbol that represents a method defined on the type that it is used.
    # If the function evaluates to false, the field will return as `nil`
    #
    # ### Examples:
    # Using a proc
    #
    # ```
    # field show: ->(_obj, _args, ctx) { ctx[:current_contract].company_editor? }
    # ```
    # Using a symbol
    #
    # ```
    # field show: :should_show_email?
    # def should_show_email?
    #   current_contract.company_editor?
    # end
    # ```
    #
    # ## authorize
    # This is a link to the PunditPolicy. It receives the symbol/string of the policy method that should be called to
    # check if the user trying to access the field has the correct permissions
    #
    # ### Example:
    # ```
    # field :contract, ContractType, authorize: :show
    # ```
    # This will run the `show?` policy from the field, it works like `authorize contract, :show?`
    #
    # ## pundit_record
    # This option defines what is the record that should be passed to the pundit policy to test. If none is passed, the
    # module will use the root object of the request.
    #
    # ### Example:
    # ```
    # field :contract, ContractType, authorize: :index, pundit_record: Contract
    # ```
    # This will run the `index?` policy passing Contract as the record, it works like `authorize Contract, :index?`
    #
    # ## policy_class
    # This option defines what is the policy class that should be used to check the permissions.
    # It is most useful on STI models like the `Objective`.
    #
    # ### Example:
    # ```
    # field :objective, ObjectiveType, authorize: :show, policy_class: ObjectivePolicy
    # ```
    # This will run the `show?` policy from the `ObjectivePolicy`, it works like `authorize objective, :show?, policy_class: ObjectivePolicy`
    class BaseField < GraphQL::Schema::Field
      # rubocop:disable Metrics/ParameterLists
      def initialize(*args,
                     show: default_show_proc,
                     authorize: nil,
                     pundit_record: nil,
                     policy_class: nil,
                     paginate: false,
                     **kwargs,
                     &block)
        # rubocop:enable Metrics/ParameterLists
        @show = show
        @authorize = authorize
        @pundit_record = pundit_record
        @policy_class = policy_class
        super(*args, **kwargs, &block)
        extension(Pagination::PaginationExtension) if paginate
        extension(PermittedFieldsExtension, null: kwargs[:null])
      end

      ##
      # This adds metadata to the Object, indicating the custom options used.
      def to_graphql
        field_defn = super
        field_defn.metadata[:show] = @show
        field_defn.metadata[:authorize] = @authorize
        field_defn.metadata[:pundit_record] = @pundit_record
        field_defn.metadata[:policy_class] = @policy_class
        field_defn
      end

      ##
      # This method adds the show/authorize logic to the field resolution.
      # It returns the new resolved field.
      def resolve_field(obj, args, ctx)
        if call_show_proc(obj, args, ctx)
          raise GraphQL::ExecutionError, 'You are not authorized to perform this action' unless authorize_proc(obj, ctx)

          super(obj, args, ctx)
        end
      end

      private

      ##
      # This method runs the actual Policy authorization method.
      # It returns a boolean indacting whether its authorized or not.
      def authorize_proc(obj, ctx)
        return true if @authorize.blank?

        pundit_query = "#{@authorize}?"
        pundit_record = @pundit_record || obj.object
        policy_class = @policy_class || infer_policy_class(pundit_record)

        policy_class.new(ctx[:policy_context], pundit_record).public_send pundit_query
      end

      ##
      # This method tries to find the correct policy from the record being evaluated.
      # It returns a Pundit policy class.
      def infer_policy_class(record)
        ::Pundit::PolicyFinder.new(record).policy!
      end

      ##
      # This method calls the `show` method correctly, running it with (obj, args, ctx) if its a proc and the referenced method
      # if its a symbol.
      # It returns the returned boolean from the `show` method passed.
      def call_show_proc(obj, args, ctx)
        if @show.respond_to?(:call)
          @show.call(obj, args, ctx)
        else
          obj.send(@show)
        end
      end

      ##
      # This is the default `show` proc that evaluates to `true`.
      # This is important for field where the proc isn't passed.
      def default_show_proc
        ->(_obj, _args, _ctx) { true }
      end
    end
  end
end
