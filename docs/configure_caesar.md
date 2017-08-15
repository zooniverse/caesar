## Configure Caesar

Caesar listens to classification events for workflows from the event stream. 
You need to let Caesar know to listen to this workflow and it has to be a
workflow you have access to in zooniverse.org.

There are two ways to configure Caesar, manually via the UI or programmatically the API. 
E.g. with a Zooniverse.org workflow id = 1234

### UI
 + Visit https://caesar.zooniverse.org/ and login.
 + Then navigate to https://caesar.zooniverse.org/workflows/new?id=1234 and click enable
 + Use the UI to configure your rules and effects as per the [rules](docs/rules.md#rules) & [effects](docs/effects.md) docs.

### API 
1. Create a workflow
    + POST JSON request to `https://caesar.zooniverse.org/workflows/id=1234`
0. Update the workflow with a configuration object payload (see [rules](docs/rules.md#rules) & [effects](docs/effects.md))
    + PUT JSON request to `/workflows/1234` with payload
```
{
  "extractors_config": { },
  "reducers_config": { }
  "rules_config": [
    {
      "if": ["gte", ["lookup", "survey-total-VHCL"], ["const", 1]], 
      "then": [{"action": "retire_subject"}]
     }
  ]
}
```
