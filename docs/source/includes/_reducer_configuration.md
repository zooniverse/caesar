# Reducers

Reducers are used to compile a set of extracts together to create an aggregated result. For example, a set of answers from a question task can be combined to get the "best" answer (i.e. one with the most votes). 

## Creating Reducers
Reducers can be created from the "Reducers" tab in the workflow configure page. Like extractors, Caesar features a set of standard reducers, which are task dependent. To add a reducer to your workflow, click on the 'Create' button and choose from dropdown: 

![new-reducer](images/new-reducer.png)

This will take you to a configuration window for that reducer:

![reducer-config](images/reducer-page.png)

All reducers share the same set of keys, but configuring reducers can be tricky because they are flexible in so many different ways. These keys will be described below:

## Key

This is the unique ID for this reducer. Use something that defines the functionality of the reducer. For example, a reducer that generates the consensus of a question task of galaxy morphology could be `galaxy-morphology-consensus`.

## Topic

Extracts are always implicitly grouped before being combined. There are two different ways of doing this: 

* `reduce_by_subject`: 

This filters all classifications by subject ID. Consequently, the aggregation will run on all classifications of a given subject. This is a useful way to get information about a specific subject. 

* `reduce_by_user`

This filters all classifications by user ID. Therefore, aggregation is done on all classifications done by that user in the current workflow. This is useful in getting statistics about specific users. 

The default is `reduce_by_subject`. 

## Grouping

This is a confusing setting because extracts are already obviously grouped according to the [topic](#topic). This allows an additional grouping pass, which, crucially, can be done on the basis of the *value* of a specified field. So to configure this, you need to set the name of the field to group by (in format `extractor_key.field_name`) and then a flag indicating how to handle when the extracts for a given classification are missing that field. The value of the grouping field will be reflected in the name of the group, stored in the `subgroup` field. The default behavior is not to perform this secondary grouping.

## Filters

This tab allows you to filter what classifications are combined together. Caesar will search and retrieve all classifications based on the `topic` key defined above. In the `filters` tab, you can further refine which classifications in this subset you want to use (default: all), and which extracts to use for that classification. These keys are described below:

### From/To
These keys allow you to subset the list of extracts to use, where from and to define the (zero-based) start and end index of the list of classifications. By default, Caesar will use all the retrieved extracts. For example, if you want everything from the 5th index to the end, set `start=5` and `end=-1`. 

### Extractor Keys
This entry allows you to subset which extracts (defined in the extractor configuration) should be used for this reducer. Sometimes multiple extractors will be defined but a particular reducer only cares about or can only work with a particular type of extract. In this case, you can use the extractor keys property to restrict the extracts that are sent to this reducer. The format of this value is either a string (for a single extractor key) or an array of strings (for multiple extractors) of the extractor keys defined in the extractor configuration in the format `["extractor-key-1", "extractor-key-2", "extractor-key-3"]`. The default, a blank string or a nil, sends all extracts.

### Repeated classifications
This prescribes what Caesar should in case there are multiple classifications by the same user ID. `keep_first` is the default value, and Caesar will remove everything but the first time the user saw the subject. `keep_last` chooses the latest classification. `keep_all` will not delete any classifications. We recommend ‘keep_first’ unless you feel strongly that you’d prefer another of those options. It’s a rare event, but good to have a rule in place for it. 

### Training behavior
This configures what Caesar should do about training data (those with metadata keys `#training_subjects`). The default behaviour is to `ignore_training` where Caesar does not actively run reductions on training subjects. This can be configured to work on `training_only`, where the reductions is only run on classifications which contain training subjects or the converse, where all training data is removed before aggregations (`experiment_only`). See [training subject metadata](#code-training_subject-code) for more info on training subjects. 

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
