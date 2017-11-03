class ApplicationOperation
  include Pundit

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
