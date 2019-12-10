# Subject Metadata

### Caesar can reflect on several attributes in a subject's metadata to know how to perform certain actions.

## `#training_subject`:
* Boolean. If true, subject is a training subject.
* Used to funnel training subjects to a separate reduction pathway.
* Example: TESS user weighting
* ExtractFilter allows filtering by training behavior.
* To use: set a filter on reducer to include:
  `training_behavior: training_only` or `experiment_only`
* See Subject#training_subject? and Filters::FilterByTrainingBehavior for use.

## `#previous_subject_ids`:
* Array of Zooniverse subject ids
* Subjects whose ids are included in array will be passed by RunsReducers to FetchExtractsBySubject
* Used to indicate that one or more prior subjects' extracts should be included when reducing a new subject.
* Example: TESS takes a new image of the same piece of the sky as a previous subject on a subsequent pass. The previous subject's Zooniverse id is included in the subject metadata and all extracts for both subjects are included in the new subject's reduction.
* See Subject#additional_subject_ids_for_reduction for use.

