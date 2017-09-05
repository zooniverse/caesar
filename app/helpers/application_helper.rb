module ApplicationHelper
  def render_condition(condition)
    render partial: 'condition', locals: {condition: condition}
  end
end
