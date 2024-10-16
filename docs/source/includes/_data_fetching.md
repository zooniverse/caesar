Fetching Caesar data, particularly a reduction, on subject load in the Classifier is becoming a more common workflow. As an example of this use case, imagine a volunteer correcting a machine-generated annotation. This guide outlines the data structure that is required for each of the supported tools below. This is meant to provide a reference for generating CSV files that can be uploaded to Caesar.

The base structure required by Caesar in the `data` field of the csv is an object - denoted as `{}` in JSON. The `data` attribute on this root object is an array of annotation objects that will be displayed on a subject. Below is the core structure shared by them all.

```js
{
  // which step in the workflow, usually S0
  "stepKey": "S0",
  // index of task in the workflow, usually 0
  "taskIndex": 0,
  // correlates with taskIndex, usually T0
  "taskKey": "T0",
  // all supported taskTypes are drawing
  "taskType": "drawing",
  // index of tool in the task, usually 0
  "toolIndex": 0,
  // usually 0 unless in multi-frame view
  "frame": 0,
  // alphanumeric string that must be unique across all annotations in the array
  "markId": "clhhuqm9",
  // supported toolType values are listed in the examples below
  "toolType": "<tool-from-below>",
}
```

## Drawing Tools

### Circle tool

```json
{
  "data": [
    {
      "stepKey": "S0",
      "taskIndex": 0,
      "taskKey": "T0",
      "taskType": "drawing",
      "toolIndex": 0,
      "frame": 0,
      "markId": "clhhuqm9",
      "toolType": "circle",
      "r": 103,
      "x_center": 574,
      "y_center": 198
    }
  ]
}
```

### Ellipse tool

```json
{
  "data": [
    {
      "stepKey": "S0",
      "taskIndex": 0,
      "taskKey": "T0",
      "taskType": "drawing",
      "toolIndex": 0,
      "frame": 0,
      "markId": "clhhuqm9",
      "toolType": "ellipse",
      "angle": 23,
      "rx": 215,
      "ry": 81,
      "x_center": 650,
      "y_center": 269
    }
  ]
}
```

### FreehandLine tool

```json
{
  "data": [
    {
      "stepKey": "S0",
      "taskIndex": 0,
      "taskKey": "T0",
      "taskType": "drawing",
      "toolIndex": 0,
      "frame": 0,
      "markId": "clhhuqm9",
      "toolType": "freehandLine",
      "pathX": [ 200, 250, 250, 200 ],
      "pathY": [ 100, 100, 150, 150 ]
    }
  ]
}
```

### Line tool

```json
{
  "data": [
    {
      "stepKey": "S0",
      "taskIndex": 0,
      "taskKey": "T0",
      "taskType": "drawing",
      "toolIndex": 0,
      "frame": 0,
      "markId": "clhhuqm9",
      "toolType": "line",
      "x1": 377,
      "x2": 690,
      "y1": 223,
      "y2": 281
    }
  ]
}
```

### Point tool

```json
{
  "data": [
    {
      "stepKey": "S0",
      "taskIndex": 0,
      "taskKey": "T0",
      "taskType": "drawing",
      "toolIndex": 0,
      "frame": 0,
      "markId": "clhhuqm9",
      "toolType": "point",
      "x": 330,
      "y": 122
    }
  ]
}
```

### Polygon tool

```json
{
  "data": [
    {
      "stepKey": "S0",
      "taskIndex": 0,
      "taskKey": "T0",
      "taskType": "drawing",
      "toolIndex": 0,
      "frame": 0,
      "markId": "clhhuqm9",
      "toolType": "polygon",
      "points": [
        { "x": 341, "y": 143 },
        { "x": 225, "y": 246 },
        { "x": 379, "y": 300 }
      ]
    }
  ]
}
```

### Rectangle tool

```json
{
  "data": [
    {
      "stepKey": "S0",
      "taskIndex": 0,
      "taskKey": "T0",
      "taskType": "drawing",
      "toolIndex": 0,
      "frame": 0,
      "markId": "clhhuqm9",
      "toolType": "rectangle",
      "height": 201,
      "width": 437,
      "x_center": 651,
      "y_center": 334
    }
  ]
}
```

### RotateRectangle tool

```json
{
  "data": [
    {
      "stepKey": "S0",
      "taskIndex": 0,
      "taskKey": "T0",
      "taskType": "drawing",
      "toolIndex": 0,
      "frame": 0,
      "markId": "clhhuqm9",
      "toolType": "rotateRectangle",
      "angle": -35,
      "height": 84,
      "width": 217,
      "x_center": 454,
      "y_center": 295
    }
  ]
}
```
