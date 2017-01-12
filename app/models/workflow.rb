class Workflow < ApplicationRecord
  def extractors
    []
  end

  def reducers
    []
  end

  def rules
    Rules::Engine.new(rules_config)
  end
end
