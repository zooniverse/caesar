# frozen_string_literal: true
class StatusController < ApplicationController
  skip_before_action :authenticate!

  def show
    skip_authorization
    @status = Rails.cache.fetch(status_cache_key, expires_in: status_cache_ttl) do
      ApplicationStatus.new
    end
    respond_with @status
  end

  private

  def status_cache_ttl
    ENV.fetch('STATUS_CACHE_TTL', 1.minute)
  end

  def status_cache_key
    ENV.fetch('STATUS_CACHE_KEY', 'app-status')
  end
end
