module ApplicationHelper
  def render_condition(condition)
    render partial: 'condition', locals: {condition: condition}
  end

  def render_params(params, empty_string)
    render partial: 'params', locals: {hash: params, empty_string: empty_string}
  end
end
