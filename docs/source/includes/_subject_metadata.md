# Subject Metadata

Caesar stores subject metadata that is fetched the first time that subject is operated on by an active Caesar workflow. Note: metadata updates made to Panoptes subjects are not automatically reflected in the Caesar stored entry. Metadata updates can only be fetched by admin-triggered actions: running a workflow backfill (via Caesar's `BackfillWorkflowWorker`), or running `update_cache()` on each `Subject` resource.

## For Rule Conditions

Caesar can reflect on subject metadata as part of a rule condition. This can be particularly helpful to make use of ML predictions, where early retirement rules take into account agreement or disagreement with a machine prediction and adjust the required number of classifications accordingly.

As an example, this rule condition checks if `#machine_confidence_is_empty` is greater than or equal to 0.5 for case where volunteers are in 100% agreement with "NOANIMALSPRESENT" after at least two classifications:

`["and", ["eq",["lookup","consensus.most_likely",""], ["const","NOANIMALSPRESENT"]], ["gte",["lookup","consensus.num_votes",0],["const",2]], ["gte",["lookup","consensus.agreement",0],["const",1]], `**`["gte",["to_f",["lookup","subject.#machine_confidence_is_empty",0]],["const",0.5]]]`**

Note: subject metadata fields will be stored as strings by default, hence the use of the `to_f` operator to convert the string value to a float for numerical comparison.

## Special Metadata

Two attributes in a subject's metadata have special significance to Caesar.

### `#training_subject`

* Boolean. If true, subject is a training subject.
* Used to funnel training subjects to a separate reduction pathway.
* Example: TESS user weighting
* ExtractFilter allows filtering by training behavior.
* To use: set a filter on reducer to include:
  `training_behavior: training_only` or `experiment_only`
* See Subject#training_subject? and Filters::FilterByTrainingBehavior for use.

### `#previous_subject_ids`

* Array of Zooniverse subject ids
* Subjects whose ids are included in array will be passed by RunsReducers to FetchExtractsBySubject
* Used to indicate that one or more prior subjects' extracts should be included when reducing a new subject.
* Example: TESS takes a new image of the same piece of the sky as a previous subject on a subsequent pass. The previous subject's Zooniverse id is included in the subject metadata and all extracts for both subjects are included in the new subject's reduction.
* See Subject#additional_subject_ids_for_reduction for use.
