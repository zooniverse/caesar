# Extracts

Extractors are tools that allow Caesar to extract specific data from the full classification output. Caesar (and the aggregations-for-caesar app) feature a collection of extractors for specific tasks. 

## Creating an extractor
To create an extractor:

+ From the workflow summary page, click on the ‘Extractors’ tab. Press the ‘+Create Extractor’ button. You will be prompted to choose a type of extractor. 

![new-extractor](images/new-extractor.png)

+ Fill out the form for the new extractor. The generic fields for all extractors are:
  + The `key` is an alpha-numeric identifier for this extractor that is unique to this workflow. Set a short, but descriptive string for this, e.g., `galaxy-type-extract`.
  + The `task key` is the identifier of the task in the workflow. You can get this information from the project builder page (see image below)
![task-key](images/extract-task-key.jpg)
  + The `if missing` entry allows you to decide what should be done if the classification data is missing. The default choice is to error out of that extract. 
  + The `minimum workflow version` provides the choice to filter out early versions of the workflow, useful for limiting the data domain to post-development or post-launch classifications.
  + Each extractor will also have unique fields that need to be filled out, as detailed below.

## Extractor types

There are different types of extractors suited for specific tasks. The following table shows the types of tools that each extractor supports. 

### Blank extractor

This extractor checks for whether a text entry (or some drawing tasks) in the classification is blank. The extractor outputs `blank=true` if the classification is empty or `false` instead. 

### Question extractor

Suited for question tasks, this extracts retrieves the index of the answer from the classification. 

### Pluck field extractor

### Survey extractor

### Shape extractor

### External extractor

## Classification data format

>Sample classification data

```json
{
  "id": 356374099,
  "project_id": 16747,
  "workflow_id": 19487,
  "workflow_version": "20.23",
  "subject_id": 67913886,
  "user_id": 2245813,
  "annotations": {
  	main task data here
  },
  "metadata": {
    "started_at": "2021-08-31T19:24:09.056Z",
    "finished_at": "2021-08-31T19:24:25.576Z",
    "live_project": false,
    "interventions": {"opt_in": true, "messageShown": false},
    "user_language": "en",
    "user_group_ids": [],
    "workflow_version": "20.23",
    "subject_dimensions": [{"clientWidth": 700, "clientHeight": 390, "naturalWidth": 700, "naturalHeight": 390}],
    "subject_selection_state": {
      "retired": false,
      "selected_at": "2021-08-31T19:24:08.886Z",
      "already_seen": false,
      "selection_state": "normal",
      "finished_workflow": false,
      "user_has_finished_workflow": false
    },
    "workflow_translation_id": "48794"
  },
  "subject": {
    "id": 67913886,
    "metadata": {
		subject metadata here
    },
    "created_at": "2021-08-31T19:24:26.032Z",
    "updated_at": "2021-08-31T19:24:26.032Z"
  }
}


```

The extractors gets the raw data from the classification. There are a set of standard fields that are common across all task types, but individual tasks contain specific data formats tailored to the data that they send. The common fields are:

+ `id` : The unique ID for the classification
+ `project_id` : The ID for the project that this classification belongs to
+ `workflow_id` : The workflow attached to the classification
+ `workflow_version` : The version for the workflow (*is this something that project builders can set?*)
+ `subject_id` : The ID for the subject that was classified
+ `user_id` : The unique ID for the user who classified this subject
+ `annotations` : Dictionary containing the actual classification data (differs based on the number of tasks, and the task types)
+ `metadata` : Additional data for this classification. Most are standard HTTP headers, except
	+ `started_at`, `finished_at` : The start and times for this classification
	+ `live_project` : whether the project is live
	+ `interventions` : data on whether the volunteer was shown any feedback messages
	+ `subject_dimensions` : The size of the subject (in pixels) on the screen
	+ `subject_selection_state` : Data about the subject's retirement state and whether it has been seen before. 
+ `subject` : Data about the subject, including
	+ `id` : The unique subject ID in the database
	+ `metadata` : Additional data about the subject (including filename, and whether it is a `gold_standard` data)


## Task specific data

> Example of annotation data

```json
  "annotations": {
    "T0": [
      {
        "task": "T0",
        "value": 0
      }
    ],
    "T1": [
      {
        "task": "T1",
        "value": [
          {
            "x": 315.75,
            "y": 151.96665954589844,
            "toolIndex": 3,
            "tool": 3,
            "frame": 0,
            "details": []
          }
        ]
      }
    ],
    "T2": [
      {
        "task": "T2",
        "value": "ffdddsssaaa"
      }
    ]
  }
```

The data for each task is passed into the `annotations` key in the JSON dictionary. The tasks are listed by the task name, with each entry containing information related to the type of task. The name of the task is stored in the `task` key, while the data associated with the task is stored in the `value` key. The `value` can very from a simple text/number to a dictionary depending on the task type. In the example on the right, the first task is a question, the second is a point tool, and the third is a text tool. A list of task-specific outputs is detailed in the sections below. 

## Tool specific data

### Question tool

>Sample task data for a simple Question task

```json
"T0": [
  {
	"task": "T0",
	"value": 0,
	"taskType": "single"
  }
```

The question tool stores the answer in the`value` key, as the index of the answer (first answer is a 0).

## Get extracts

```http
GET /workflows/$WORKFLOW_ID/extractors/$EXTRACTOR_KEY/extracts?subject_id=$SUBJECT_ID HTTP/1.1
Content-Type: application/json
Accept: application/json
Authorization: Bearer $TOKEN
```

> The above command returns JSON structured like this:

```json
[
    {
        "classification_at": "2017-05-16T15:51:13.544Z",
        "classification_id": 54376560,
        "created_at": "2017-05-16T20:37:39.124Z",
        "data": null,
        "extractor_key": "c",
        "id": 411083,
        "subject_id": 458033,
        "updated_at": "2017-05-16T20:37:39.124Z",
        "user_id": 108,
        "workflow_id": 4084
    }
]
```

Extracts are pieces of information relating to a specific classification (and therefore to a specific subject as well).

### Query Parameters

Parameter     | Default | Description
------------- | ------- | -----------
WORKFLOW_ID   | null    | **Required** &middot; Specifies which workflow
SUBJECT_ID    | null    | **Required** &middot; Specifies which subject
EXTRACTOR_KEY | null    | **Required** &middot; Specifies which extractor to fetch extracts from.

## Create &amp; update extracts

Inserting and updating extracts happens through one and the same API endpoint, which performs an "upsert".

```http
POST /workflows/$WORKFLOW_ID/extractors/$EXTRACTOR_KEY/extracts HTTP/1.1
Content-Type: application/json
Accept: application/json
Authorization: Bearer $TOKEN

{
    "subject_id": 458033,
    "classification_at": "2017-05-16T15:51:13.544Z",
    "classification_id": 54376560,
    "user_id": 108,
    "data": {"PENGUIN": 1, "POLARBEAR": 4}
}
```

### Body fields

The request body should be encoded as a JSON with the following fields:

Parameter    | Default | Description
------------ | ------- | -----------
subject_id   | null     | **Required** &middot; Specifies which subject this extract is about
classification_id | null | **Required** &middot; Specifies which classification this extract is about.<br>May be omitted if known to be an update rather than a create.
classification_at | null | **Required** &middot; Specifies what time the classification happened. This is used to sort extracts by classification time when reducing them.<br>May be omitted if known to be an update rather than a create.
user_id | null | User that made the classification. `null` signifies anonymous.

