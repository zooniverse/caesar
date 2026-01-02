class Extract < ApplicationRecord
  attr_accessor :relevant_reduction

  belongs_to :workflow, counter_cache: true
  belongs_to :subject
  has_and_belongs_to_many_with_deferred_save :subject_reduction
  has_and_belongs_to_many_with_deferred_save :user_reduction

  def as_json(*)
    super(methods: :relevant_reduction)
  end
end
