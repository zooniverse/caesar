# Extracts

Extractors are tools that allow Caesar to extract specific data from the full classification output. Caesar (and the aggregations-for-caesar app) feature a collection of extractors for specific tasks. 

## Extractor types

There are different types of extractors built into Caesar for specific tasks. The following sections shows the types of tools that each extractor supports. 

### Blank extractor

This extractor checks for whether a text entry (or some drawing tasks) in the classification is blank. The extractor outputs `blank=true` if the classification is empty or `false` instead. 

### Question extractor

Suited for question tasks, this extracts retrieves the index of the answer from the classification. Indices are C-style, i.e. the first index is `"0"`.

### Pluck field extractor

This extractor is used to retrieve a value from the classification/subject metadata. For example, if the filename of the subject is used during aggregation, this extractor would pass it as an extracted value. 

### Survey extractor

### Shape extractor

### External extractor
The External Extractor API passes the classification data to an external (HTTPS) URL, which responds with the extracted data in a JSON format. See the [External API](#external-api-calls) section below for more information. 

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

