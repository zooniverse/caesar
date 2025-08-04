class ApplicationOperation
  include Pundit::Authorization

  # Our GraphQL API uses Javascript style camelCase, this class exists to convert that into snake_case.
  # There's some discussion of adding this converter directly into graphql-ruby, so before the resolve
  # function gets called. If that happens, we could get rid of this class.
  class GraphQLWrapper
    def initialize(klass)
      @klass = klass
    end

    def call(obj, args, ctx)
      @klass.call(obj,
                  args.to_h.transform_keys { |key| key.to_s.underscore }.with_indifferent_access,
                  ctx.to_h.transform_keys { |key| key.to_s.underscore }.with_indifferent_access)
    end
  end

  def self.graphql
    GraphQLWrapper.new(self)
  end

  def self.call(obj, args, ctx)
    operation = new(ctx)
    result = operation.call(obj, args)
    operation.send(:verify_authorized)
    result
  end

  attr_reader :credential

  def initialize(ctx)
    @credential = ctx[:credential]
  end

  # This method is defined to turn +query+ from an optional argument into a required one.
  # The one we get from Pundit tries to discover the query from the params[:action] which
  # does not exist outside the scope of a Rails controller.
  def authorize(record, query)
    super(record, query)
  end

  def pundit_user
    credential
  end
end
