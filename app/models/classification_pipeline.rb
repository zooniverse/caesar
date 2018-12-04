module ClassificationPipeline
  def extractors_runner
    RunsExtractors.new(self.class, extractors)
  end

  def reducers_runner
    RunsReducers.new(self.class, reducers)
  end

  def rules_runner
    RunsRules.new(self.class, subject_rules.rank(:row_order), user_rules.rank(:row_order), rules_applied)
  end
end
