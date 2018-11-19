module Extractors
  class RetrieveSubjectReductionExtractor < Extractor
    config_field :reducer_key
    config_field :default_value

    def extract_data_for(classification)
      query = SubjectReduction.where(
        workflow_id: classification.workflow_id,
        subject_id: classification.subject_id,
        reducer_key: reducer_key
      )

      return default_value if query.empty?

      raise StandardError.new('Multiple matching reductions') if query.count > 1

      query.first.data
    end
  end
end