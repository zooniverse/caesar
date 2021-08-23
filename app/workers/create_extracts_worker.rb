# frozen_string_literal: true
class CreateExtractsWorker
  include Sidekiq::Worker

  def perform(extracts)
    Extract.import extracts, validate: false
  end
end
