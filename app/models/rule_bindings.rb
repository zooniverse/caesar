class RuleBindings
  class OverlappingKeys < StandardError; end

  class SubjectBindings
    def initialize(subject)
      @subject = subject
    end

    def data
      return {} unless @subject
      @data ||= @subject.metadata.merge("zooniverse_subject_id" => @subject.id)
    end
  end

  def initialize(reductions, subject)
    @reductions = reductions.index_by(&:reducer_key)
    @reductions.merge!("subject" => SubjectBindings.new(subject)) unless subject.blank?
  end

  def fetch(key, default=nil)
    reducer_key, data_key = key.split(".")
    return @reductions.fetch(reducer_key) if data_key.nil?
    return default unless @reductions.key?(reducer_key)
    @reductions.fetch(reducer_key).data.fetch(data_key, default)
  end

  def keys
    @bindings.keys
  end

  def self.merge(results)
    results.reduce({}) do |memo, obj|
      raise OverlappingKeys, "left: #{memo.keys.inspect}, right: #{obj.keys.inspect}" if overlap?(memo, obj)
      memo.merge(obj)
    end
  end

  def self.overlap?(a, b)
    (a.keys & b.keys != [])
  end
end
