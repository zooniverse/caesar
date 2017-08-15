## Effects

Currently there are only a few valid effects that can be run after matching a rule, 
they are defined in this [code](https://github.com/zooniverse/caesar/blob/master/app/models/effects.rb).

| Effect Key | Effect Code |
| ---------- | ------------|
| `retire_subject` | [Effects::RetireSubject](app/models/effects/retire_subject.rb) |
| `add_subject_to_set` | [Effects::AddSubjectToSet](app/models/effects/add_subject_to_set.rb) |
| `add_subject_to_collection` | [Effects::AddSubjectToCollection](app/models/effects/add_subject_to_collection.rb) |
 
See the [rules](docs/rules.md#rules) documentation to learn how to wire rules and effects up.


