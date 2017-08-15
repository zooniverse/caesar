# Rules

```json
{
  "extractors": {},
  "reducers": {},
  "rules": [
      {
          "if": ["gte", ["lookup", "survey-total-VHCL"], ["const", 1]],
          "then": [{"action": "retire_subject", "reason": "flagged"}]
      }
  ]
}
```
A workflow can configure an array of rules. Each rule has a condition (`if`) and an array of effects (`then`) that happen when that condition evaluates to true.


## Condition

The condition is a single operation, but some types of operations can be nested. The general syntax is like if you'd write Lisp in JSON. It's always an array with as the first item a string identifying the operator. The other values are operations in themselves: `[operator, arg1, arg2, ...]`.

* `["lt", operation, operation, ...]` - Performs numerical comparison. You can specify more than two arguments, and it will evaluate as `a < b < c < d`.
* `["lte", operation, operation, ...]` - Performs numerical comparison. You can specify more than two arguments, and it will evaluate as `a <= b <= c <= d`.
* `["gt", operation, operation, ...]` - Performs numerical comparison. You can specify more than two arguments, and it will evaluate as `a > b > c > d`.
* `["gte", operation, operation, ...]` - Performs numerical comparison. You can specify more than two arguments, and it will evaluate as `a >= b >= c >= d`.
* `["eq", operation, operation, ...]` - Performs numerical comparison. You can specify more than two arguments, and it will evaluate as `a == b == c == d`.
* `["const", value]` - Always returns the configured value.
* `["lookup", key]` - Look up a reduction value by the given key.
* `["not", operation]` - Negates the operation
* `["and", operation, operation, ...]` - Returns true if all of the given operations evaluate to logical true
* `["or", operation, operation, ...]` - Returns true if any of the given operations evaluates to logical true
