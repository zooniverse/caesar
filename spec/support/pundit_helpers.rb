def records_for(credential)
  model_class = subject.to_s.gsub(/Policy$/, '').constantize
  Pundit.policy_scope!(credential, model_class)
end

def skip_authorization(model)
  expect(controller).to receive(:authorize).with(model).and_return(true)
end
