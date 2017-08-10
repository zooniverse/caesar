def records_for(credential)
  model_class = subject.to_s.gsub(/Policy$/, '').constantize
  Pundit.policy_scope!(credential, model_class)
end
