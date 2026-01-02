class UserReduction < ApplicationRecord
  include BelongsToReducibleCached

  has_and_belongs_to_many_with_deferred_save :extracts
end
