# Reducer Configuration

Configuring reducers can be tricky because they are flexible in so many different ways.

## Extractor Keys

Sometimes multiple extractors will be defined but a particular reducer only cares about or can only work with a particular type of extract. In this case, you can use the extractor keys property to restrict the extracts that are sent to this reducer. The format of this value is either a string (for a single extractor key) or an array of strings (for multiple extractors). The default, a blank string or a nil, sends all extracts.

## Topic

Extracts are always implicitly grouped before being combined. There are two different ways of doing this, whose names are hopefully self-explanatory. The default is `reduce_by_subject`

* `reduce_by_subject`
* `reduce_by_user`

## Grouping

This is a confusing setting because extracts are already obviously grouped according to the [topic](#topic). This allows an additional grouping pass, which, crucially, can be done on the basis of the *value* of a specified field. So to configure this, you need to set the name of the field to group by (in format `extractor_key.field_name`) and then a flag indicating how to handle when the extracts for a given classification are missing that field. The value of the grouping field will be reflected in the name of the group, stored in the `subgroup` field. The default behavior is not to perform this secondary grouping.

## Reduction Mode

This is probably the least understood part of configuring reducers. Briefly, the system offers two very different modes of performing reduction. These are:

* `default_reduction`
* `running_reduction`

### Default Reduction

In "default reduction" mode, each time a new extract is created, we fetch all of the other extracts for that subject (or user) and send them all to the reducer for processing. In cases where extracts are coming in very quickly, this can create some extra work fetching extracts, but is guaranteed to be free of race conditions because each new reduction will get a chance to reduce across all relevant extracts. This mode is much simpler and is preferred in almost every case. However, in the case where a given subject (or user) is likely to have thousands of associated extracts, it is recommended to use "running reduction" mode.

### Running Reduction

"Running reduction" mode was created to support the Notes for Nature use case, where we are reducing across a user's entire classification history within a given project, which could run to tens of thousands of items for power users. In this use case, fetching all 10,000 extracts each time a new extract is created is impractical and the operations we want to perform are relatively simple to perform using only the new extracts created in a given extraction pass.

When a reducer is configured for running reduction, each time a new classification produces new extracts, the reducer is invoked with only those new extracts. Any additional information it would need in order to correctly compute the reduction should be present in a field *on* the reduction, called a `store`. With the new extracts and the store, the reducer will compute an updated value and update its store appropriately. However, this can't be done in a multithreaded way or else the object might be available while in an inconsistent state (example: its store has been updated but its value has not). Accordingly, we use optimistic locking semantics, so that we prefetch all possible relevant extracts and reductions before reducing and throw a sync error if the object versions don't match when we try to save. Further, we need to avoid updating the reduction multiple times with the same extract, which is not a concern with running reduction. Therefore, this mode populates a relation tracking which extracts have been incorporated into which reductions. Between this and the synchronization retries, there is considerable added complexity and overhead compared to default reduction mode. It's not recommended to use running reduction mode with external reducers, because the added complexity of writing reducers that reduce from a `store`.

### Reduction Mode Example
See [Reduction Mode Example](Reduction-Mode-Example)