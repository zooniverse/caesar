# frozen_string_literal: true

class ErrorLogger
  def self.report(exception)
    Raven.capture_exception(exception)
  end
end
