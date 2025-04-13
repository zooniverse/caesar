class SubjectReduction < ApplicationRecord
  include BelongsToReducibleCached

  belongs_to :subject
  has_and_belongs_to_many_with_deferred_save :extracts

  def prepare
    {
      id: id,
      reducible: { id: reducible_id, type: reducible_type },
      data: data,
      subject: subject.attributes,
      reducer_key: reducer_key,
      created_at: created_at,
      updated_at: updated_at
    }.with_indifferent_access
  end
end
