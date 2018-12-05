module ClassificationPipeline
  def extractors_runner
    RunsExtractors.new(self, extractors)
  end

  def reducers_runner
    RunsReducers.new(self, reducers)
  end

  def rules_runner
    RunsRules.new(self, subject_rules.rank(:row_order), user_rules.rank(:row_order), rules_applied)
  end
end
