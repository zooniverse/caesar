# Caesar Data Model

## External API calls
When an ExternalExtractor or ExternalReducer the classification data is sent to the given URL (requires HTTPS) as JSON data. The external API then does the processing and returns a response to Caeser. The response from the external endpoint must be:

+ 200 (OK) 
+ 201 (Resource Created)
+ 202 (Processing Started)
+ 204 (No Data)

All other responses will result in an error on Caesar. The data format for the sent/received data differ based on whether the endpoint is an extractor or a reducers. Details are given below:

## ExternalExtractor data format

>Sample Caesar output to ExternalExtractor

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
The ExternalExtractor gets the raw data from the classification. There are a set of standard fields that are common across all task types, but individual tasks contain specific data formats tailored to the data that they send. The common fields are:

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

## Data Formats for Extractors
In this section, we outline the JSON data format details to be passed to different extractors in the aggregation-caeser API.

>Sample task data for a simple Question extractor

```json
"T0": [
  {
	"task": "T0",
	"value": 0,
	"taskType": "single"
  }
```

### Question Extractor 


The question extract retrieves the `value` key from a task. For a normal
question task, the value is the index of the answer (first answer is a
0), and how many times that answer has been chosen. 

> returns

```json
{
    "0": 1,
    "aggregation_version": "3.6.0"
}
```


> Example data for a Rectangle Extractor

```json
 "T1": [
      {
        "task": "T1",
        "value": [
          {
            "x": 190.0546875,
            "y": 292.55859375,
            "tool": 1,
            "angle": -36.34308118417328,
            "frame": 0,
            "width": 313.40234375,
            "height": 149.66796875,
            "details": []
          }
        ]
      }
    ],
```

### Rectangle Extractor

A rectangle extractor takes the following information from the data dump (in the specified format on the right) to extract details of the rectangles specified by the classifier.


#### Input
+ `x`: x coodrinate of the rectangle's centroid.
+ `y`: y coordinate of the rectangle's centroid.
+ `tool`: tool id of the rectangle?
+ `angle`: rotation angle of the rectangle.
+ `frame`: ???
+ `width`: width of the rectangle.
+ `height`: height of the rectangle.



>Example output of the rectangle extractor

```json
{
    "aggregation_version": "3.6.0",
    "frame0": {
        "T1_tool1_height": [
            149.66796875
        ],
        "T1_tool1_width": [
            313.40234375
        ],
        "T1_tool1_x": [
            190.0546875
        ],
        "T1_tool1_y": [
            292.55859375
        ]
    }
}
```

#### Output
The parameters follow the general format of TaskIdentifier_ToolIdentifier 

+ `frameX`: ??
+ `T*_tool*_height`: The width of the .
+ `T*_tool*_width`: The height of the tool ()



>Sample task data for a Circle Extractor

```json
"T1": [
      {
        "task": "T1",
        "value": [
          {
            "r": 82.84781455160156,
            "x": 276.80859375,
            "y": 317.0390625,
            "tool": 0,
            "angle": 159.37755608105448,
            "frame": 0,
            "details": []
          }
        ]
]
```
### Circle Extractor

+ `task`: task identifier
+ `r`: Radius of the circle.
+ `x`: x coordinate of the circle's center.
+ `y`: y coordinate of the circle's center.
+ `tool`: ??
+ `angle`: azimuthal rotation angle??




> Sample data for the tasks empty extractor
> Multiple tasks where each task is empty:

```json
    "T0": [
      {
        "task": "T0"
      }
    ],
    "T1": [
      {
        "task": "T1"
      }
    ]
```
### All Tasks Empty extractor

This extractor checks whether all tasks in the classification are empty. 
If all tasks do not have a `value` key, then the extractor returns the 
`result` key as `True`. If any of the tasks have a classification, then 
the `result` key is `False`. 

> returns

```json
{
    "aggregation_version": "3.6.0",
    "result": true
}
```

> Sample data for point extractor

```json
"T1": [
  {
	"task": "T1",
	"value": [
	  {
		"x": 278.75,
		"y": 141.96665954589844,
		"tool": 3,
		"frame": 0,
		"details": []
	  }
	]
  }
]

```

### Point extractor
This extractor obtains the x, y coordinate values of the point task. Note that in this case,
the external URL must also contain the task ID (e.g., [https://aggregation-caesar.zooniverse.org/extractors/point_extractor?task=T1](https://aggregation-caesar.zooniverse.org/extractors/point_extractor?task=T1)) so that the extractor has information about the task from which to extract the coordinate values. In this case, the following values are used as input in the `value` key:

+ `x` : The x-coordinate of the point
+ `y` : The y-coordinate of the point
+ `tool`: (I think this is the index of the tool on the front end?)
+ `frame` : .... no clue
+ `details` : .... no clue

The returned values are in the format `[taskID]_tool[toolID]_[x/y]`, similar to the other shape extractors above. 

> returns

```json
{
    "T1_tool3_x": [
        278.75
    ],
    "T1_tool3_y": [
        141.96665954589844
    ],
    "aggregation_version": "3.6.0"
}
```
