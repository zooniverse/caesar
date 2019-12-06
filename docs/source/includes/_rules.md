# Rules

A workflow can configure one or many rules. Each rule has a condition and one or more effects that happen when that condition evaluates to true. Conditions can be nested to achieve complicated if statements.

Rules may pertain to either subjects or users. Rules have an evaluation order that can be set in the database if need be, and then rules can either be all evaluated or evaluated until the first true condition is reached.

## Conditions

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

## Sample conditions

### If one or more vehicles is detected

From the console:
```ruby
SubjectRule.new
  workflow_id: 123,
  condition: ['gte', ['lookup', 'survey-total-VHCL'], ['const', 1]],
  row_order: 1
```

Input into UI:
```json
  ["gte", ["lookup", "survey-total-VHCL"], ["const", 1]]
```

### If the most likely identification is "HUMAN"

From the console:
```ruby
SubjectRule.new
  workflow_id: 123,
  condition: ['gte', ['lookup', 'consensus.most_likely', ''], ['const', 'HUMAN']],
  row_order: 3
```
Input into UI:
```json
  ["gte", ["lookup", "consensus.most_likely", ""], ["const", "HUMAN"]]
```


## Effects

Each rule can have one or more effects associated with it. Those effects will be performed when that rule's condition evaluates to true. Subject Rules have effects that affect subjects (and implicitly receive `subject_id` as a parameter) and User Rules have effects that affect users (`user_id`).

### Subject Rule Effects

| effect_type | `config` Parameters | Effect Code |
| ---------- | ---------- | ------------|
| `retire_subject` | `reason` (string)\* | [Effects::RetireSubject](https://github.com/zooniverse/caesar/blob/master/app/models/effects/retire_subject.rb)                      |
| `add_subject_to_set` | `subject_set_id` (string)| [Effects::AddSubjectToSet](https://github.com/zooniverse/caesar/blob/master/app/models/effects/add_subject_to_set.rb) |
| `add_subject_to_collection` | `collection_id` (string) | [Effects::AddSubjectToCollection](https://github.com/zooniverse/caesar/blob/master/app/models/effects/add_subject_to_collection.rb) |
| `external_effect` | `url` (string)** | [Effects::ExternalEffect](https://github.com/zooniverse/caesar/blob/master/app/models/effects/add_subject_to_collection.rb)

<sub>\* Panoptes API validates `reason` against a list of permitted values. Choose from `blank`, `consensus`, or `other`</sub>

<sub>\** `url` must be HTTPS</sub>

### User Rule Effects

| effect_type | `config` Parameters | Effect Code |
| ---------- | ---------- | ------------|
| `promote_user` | `workflow_id` (string) | [Effects::ExternalEffect](https://github.com/zooniverse/caesar/blob/master/app/models/effects/promote_user.rb)

## Sample Effects

### Retire a subject

From the console:

```ruby
SubjectRuleEffect.new
  rule_id: 123,
  effect_type: 'retire_subject',
  config: { reason: 'consensus' }
```

In the UI:

These can be configured in the UI normally, there's nothing complicated like the `condition` field.

### Promote a user to a new workflow

From the console:
```ruby
UserRuleEffect.new
  rule_id: 234,
  effect_type: 'promote_user',
  config: { 'workflow_id': '555' }
```
