class PerformReduction
  attr_reader :workflow

  def initialize(workflow)
    @workflow = workflow
  end

  def reduce(subject_id, user_id)
    tries ||= 2

    extracts = ExtractFetcher.new(workflow.id, subject_id, user_id)

    reducers.map do |reducer|
      data = if reducer.reduce_by_subject?
        reducer.process(extracts.subject_extracts)
      elsif reducer.reduce_by_user?
        reducer.process(extracts.user_extracts)
      else
        Reducer::NoData
      end

      return if data == Reducer::NoData

      data.map do |subgroup, datum|
        next if data == Reducer::NoData

        reduction = if reducer.reduce_by_subject?
            SubjectReduction.where(
              workflow_id: workflow.id,
              subject_id: subject_id,
              reducer_key: reducer.key,
              subgroup: subgroup).first_or_initialize
          elsif reducer.reduce_by_user?
            UserReduction.where(
              workflow_id: workflow.id,
              user_id: user_id,
              reducer_key: reducer.key,
              subgroup: subgroup).first_or_initialize
          else
            nil
          end

        reduction.data = datum
        reduction.subgroup = subgroup
        reduction.save!

        reduction
      end
    end.flatten
  rescue ActiveRecord::RecordNotUnique, PG::UniqueViolation
    sleep 2
    retry unless (tries-=1).zero?
    raise
  end

  private

  def reducers
    workflow.reducers
  end
end
