module Conditions
  class Any
    def initialize(dict_name, operation)
      @dict_name = dict_name
      @operation = operation
    end

    def apply(bindings)
      dict = bindings.fetch(@dict_name)
      dict.keys.any? { |key| @operation.apply({"key" => key, "value" => dict.fetch(key)}) }
    end
  end
end
