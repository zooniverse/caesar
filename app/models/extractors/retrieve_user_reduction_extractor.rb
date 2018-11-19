module Extractors
  class RetrieveUserReductionExtractor < Extractor
    config_field :reducer_key
    config_field :default_value

    def extract_data_for(classification)
      query = UserReduction.where(
        workflow_id: classification.workflow_id,
        user_id: classification.user_id,
        reducer_key: reducer_key
      )

      return default_value if query.empty?

      raise StandardError.new('Multiple matching extracts') if query.count > 1

      query.first.data
    end
  end
end