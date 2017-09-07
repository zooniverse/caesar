class GraphqlController < ApplicationController
  def execute
    skip_authorization

    variables = ensure_hash(params[:variables])
    query = params[:query]
    operation_name = params[:operationName]
    context = {
      # Query context goes here, for example:
      credential: credential,
    }
    logger.info credential.inspect
    result = CaesarSchema.execute(query, variables: variables, context: context, operation_name: operation_name)
    render json: result
  end

  private

  def authenticated?
    # Hairy code warning:
    # We need to attempt to load the credential so that `authenticate!`
    # will catch errors associated with loading invalid tokens,
    # and will have a chance to handle redirects and expired session management.
    credential

    # But, we don't actually care whether or not there is a logged-in user, since
    # the GraphQL API also supports some anonymous calls.
    true
  end

  def authorized?
    true
  end

  def record_not_found(exception)
    logger.info(exception.message)
    head 404
  end

  # Handle form data, JSON body, or a blank value
  def ensure_hash(ambiguous_param)
    case ambiguous_param
    when String
      if ambiguous_param.present?
        ensure_hash(JSON.parse(ambiguous_param))
      else
        {}
      end
    when Hash, ActionController::Parameters
      ambiguous_param
    when nil
      {}
    else
      raise ArgumentError, "Unexpected parameter: #{ambiguous_param}"
    end
  end
end
