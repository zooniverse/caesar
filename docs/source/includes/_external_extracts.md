## External API calls
When an ExternalExtractor or ExternalReducer is called the classification data is sent to the given URL (requires HTTPS) as JSON data. The external API then does the processing and returns a response to Caeser. The response from the external endpoint must be:

+ 200 (OK) 
+ 201 (Resource Created)
+ 202 (Processing Started)
+ 204 (No Data)

All other responses will result in an error on Caesar. The data format for the sent/received data differ based on whether the endpoint is an extractor or a reducers. Details are given below:


## Data Formats for Extractors
In this section, we outline the JSON data format details to be passed to different extractors in the aggregation-caeser API. If you have a custom ExternalExtractor API, you must make sure that the input and output data is in the same format as shown here. 

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




## Shape Extractor
This is a general-purpose extractor that can retrieve information regarding various shape tools used. One can specify which shape information to extract by passing the `task identifier` (e.g., `T0`) and `shape=name` (e.g., `shape=rectangle`) as such: `https://aggregation-caesar.zooniverse.org/extractors/shape_extractor?task=T1&shape=circle`. The following are the list of shapes that you can extract using the shape extractor:

+ `Rectangle Extractor`
+ `Circle Extractor`
+ `Point Extractor`
+ `Line Extractor`


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

A rectangle extractor takes the following information from the data dump (in the specified format on the right) to extract details of the rectangles specified by the classifier. The usage is `https://aggregation-caesar.zooniverse.org/extractors/shape_extractor?task=T1&shape=rectangle`

__Note__: There is a dedicated `Rectangle Extractor` that one can use instead of the shape extractor by `https://aggregation-caesar.zooniverse.org/extractors/rectangle_extractor?task=T1`, where `task=T*` should be the task identifier corresponding to the rectangle tool usage task.

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
You can use the `shape=circle` argument to specify the shape extractor to get the information of the circle tool used in the classification task. Example usage is: `https://aggregation-caesar.zooniverse.org/extractors/shape_extractor?task=T1&shape=circle`, where `task=T*` is the task corresponding to the circle tool.

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

### Point extractor/Point extractor by frame
This extractor obtains the x, y coordinate values of the point task. Note that in this case,
the external URL must also contain the task ID (e.g., [https://aggregation-caesar.zooniverse.org/extractors/point_extractor?task=T1](https://aggregation-caesar.zooniverse.org/extractors/point_extractor?task=T1)) so that the extractor has information about the task from which to extract the coordinate values. In this case, the following values are used as input in the `value` key:

+ `x` : The x-coordinate of the point
+ `y` : The y-coordinate of the point
+ `tool`: (I think this is the index of the tool on the front end?)
+ `frame` : .... no clue
+ `details` : .... no clue

The returned values are in the format `[taskID]_tool[toolID]_[x/y]`, similar to the other shape extractors above. 

The `point_extractor_by_frame` extractor performs a similar function, except at the output level, where each (x,y) coordinate value is categorized by the frame number:

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

> or with the `point_extractor_by_frame`:

```json
{
    "aggregation_version": "3.6.0",
    "frame0": {
        "T1_tool3_x": [
            278.75
        ],
        "T1_tool3_y": [
        	141.96665954589844
        ]
    }
}
```

### Line Extractor 
A line extraction functionality in the shape extractor retrieves the information of the `(x1,y1)` and `(x2,y2)` points of the line. Example usage is: `https://aggregation-caesar.zooniverse.org/extractors/shape_extractor?task=T1&shape=line`, where `task=T*` is the task corresponding to the line tool.

> Sample input data to line extractor

```json
{
          {
            "x1": 191.75,
            "x2": 647.75,
            "y1": 477.9666748046875,
            "y2": 295.9666748046875,
            "tool": 2,
            "frame": 0,
            "details": []
          }
}
```

> Output of the line extraction

```json
{
    "aggregation_version": "3.6.0",
    "frame0": {
        "T1_tool2_x1": [
            191.75
        ],
        "T1_tool2_x2": [
            647.75
        ],
        "T1_tool2_y1": [
            477.9666748046875
        ],
        "T1_tool2_y2": [
            295.9666748046875
        ]
    }
}
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
