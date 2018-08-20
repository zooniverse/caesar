module ApplicationHelper
  def render_condition(condition)
    render partial: 'condition', locals: {condition: condition}
  end

  def render_hash(hash, empty_string)
    render partial: 'hash', locals: {hash: hash, empty_string: empty_string}
  end
end
