---
title: API Reference

language_tabs: # must be one of https://git.io/vQNgJ
  - http

toc_footers:
  - <a href='#'>Sign Up for a Developer Key</a>
  - <a href='https://github.com/tripit/slate'>Documentation Powered by Slate</a>

includes:
  - how_to_swap
  - extracts
  - rules
  - errors

search: true
---

# Introduction

Caesar listens to classification events for workflows from the event stream.
You need to let Caesar know to listen to this workflow and it has to be a
workflow you have access to in zooniverse.org.

There are two ways to configure Caesar, manually via the UI or programmatically the API.
E.g. with a Zooniverse.org workflow id = 1234

## Configuring Caesar via the Web UI
 + Visit https://caesar.zooniverse.org/ and login.
 + Then navigate to https://caesar.zooniverse.org/workflows/new?id=1234 and click enable
 + Use the UI to configure your rules and effects as per the [rules](#rules) & [effects](#effects) docs.

## Configuring Caesar via the API
1. Create a workflow
    + POST JSON request to `https://caesar.zooniverse.org/workflows/?id=1234`
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

# Authentication

> To authenticate, use an OAuth bearer token obtained from Panoptes:

```shell
# With shell, you can just pass the correct header with each request
curl "api_endpoint_here"
  -H "Authorization: Bearer xyz"
```

Caesar uses the same OAuth bearer token as Panoptes to allow access to the API. By default any data relating to a workflow is only accessible to project owners and collaborators.

Caesar expects for the bearer token to be included in all API requests to the server in a header that looks like the following:

`Authorization: Bearer xyz`

<aside class="notice">
You must replace <code>xyz</code> with your personal API key.
</aside>
