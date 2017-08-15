# Extracts

## Get all extracts

```shell
curl "http://example.com/workflows/WORKFLOW_ID/subjects/SUBJECT_ID"
  -H "Authorization: Bearer xyz"
```

> The above command returns JSON structured like this:

```json
[
  {
    "id": 1,
    "name": "Fluffums",
    "breed": "calico",
    "fluffiness": 6,
    "cuteness": 7
  },
  {
    "id": 2,
    "name": "Max",
    "breed": "unknown",
    "fluffiness": 5,
    "cuteness": 10
  }
]
```

This endpoint retrieves all kittens.

### HTTP Request

`GET http://example.com/workflows/WORKFLOW_ID/subjects/$SUBJECT_ID/extracts`

### Query Parameters

Parameter    | Default | Description
------------ | ------- | -----------
WORKFLOW_ID  | nil     | Required, specifies which workflow
SUBJECT_ID   | nil     | Required, specifies which subject
extractor_id | nil     | Specifies which extractor to fetch extracts from, if present
