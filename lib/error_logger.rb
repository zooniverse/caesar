class ErrorLogger
  def self.report(exception)
    Raven.capture_exception(exception)
  end
end
