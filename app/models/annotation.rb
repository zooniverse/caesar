class Annotation
  def self.parse(arr)
    Annotation.parse_helper(arr).group_by{ |ann| ann['task'] }
  end

  def self.parse_helper(arr)
    arr.map do |item|
      if Annotation.nested?(item['value'], 'task')
        Annotation.parse_helper(item['value'])
      elsif Annotation.nested?(item['value'], 'value')
        item['value'].map{ |inneritem| inneritem.merge('task' => item['task'])}
      else
        [ { 'task' => item['task'], 'value' => item['value'] } ]
      end
    end.flatten(1)
  end

  def self.nested?(arr, key)
    return false unless arr.is_a? Array
    return false unless arr.all?{ |item| item.is_a? Hash }
    arr.any?{ |val| val.key?(key)}
  end
end