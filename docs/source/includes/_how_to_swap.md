# How to do SWAP

> In Panoptes, set `workflow.configuration` to something like:

```
{"subject_set_chances": {"EXPERT_SET_ID": 0}}
```

> In Caesar, set the workflow like so:

```json
{
  "extractors_config": {
    "who": {"type": "who"},
    "swap": {"type": "external", "url": "https://darryls-server.com"} # OPTIONAL
  },
  "reducers_config": {
    "swap": {"type": "external"},
    "count": {"type": "count"}
  }
  "rules_config": [
    {"if": [RULES], "then": [{"action": "retire_subject"}]}
  ]
}
```

> When you detect an expert user, update their probabilities like this:

```http
POST /api/project_preferences/update_settings?project_id=PROJECT_ID&user_id=USER_ID HTTP/1.1
Host: panoptes-staging.zooniverse.org
Authorization: Bearer TOKEN
Content-Type: application/json
Accept: application/vnd.api+json; version=1

{
  "project_preferences": {
    "designator": {
      "subject_set_chances": {
        "WORKFLOW_ID": {"SUBJECT_SET_ID": 0.5}
      }
    }
  }
}
```

> And store expert-seenness in Caesar so that you can use it in the rulse

```http
POST /workflows/WORKFLOW_ID/reducers/REDUCER_ID/reductions HTTP/1.1
Host: caesar-staging.zooniverse.org
Authorization: Bearer TOKEN
Content-Type: application/json
Accept: application/json

{
  "likelyhood": 0.864,
  "seen_by_expert": false
}
```

This document is a reference to the current state of affairs on doing SWAP on
the Panoptes platform (by which we mean the Panoptes API, Caesar, and
Designator).

To do SWAP, one must:

1. **Track the confusion matrix of users**. We currently expect this to be done
   by some entity outside the Panoptes platform. This could be a script that
   runs periodically on someone's laptop, or it can be an external webservice
   that gets classifications streamed to it in real-time by Caesar (this is what
   Darryl is doing). We don't currently have a good place to store the confusion
   matrix itself inside the Panoptes platform. But, if the matrix identifies an
   expert classifier, post that into Panoptes under the `project_preferences`
   resource (API calls explained in later section)

2. **Calculate the likelyhood of subjects**. This is done in the same place that
   also calculates the confusion matrices. The resulting likelyhood should be
   posted into Caesar as a `reduction`.

3. **Retire subjects when we know the answer**. By posting the likelyhood into Caesar,
   we can set rules on it. For instance:
   * `IF likelyhood < 0.1 AND classifications_count > 5 THEN retire()`
   * `IF likelyhood > 0.9 AND classifications_count > 5 THEN retire()`
   * `IF likelyhood > 0.1 AND likelyhood < 0.9 AND not seen_by_expert AND classifications > 10 THEN move to expert_set`

4. When Caesar moves subjects into an expert-only subject set, Designator can then serve subjects from that set only to users marked as experts by the `project_preferences`. Designator is all about serving subjects from sets with specific chances, which means that we avoid the situation where experts only ever see the really hard subjects by mixing e.g. 50% hard images with 50% "general population".
