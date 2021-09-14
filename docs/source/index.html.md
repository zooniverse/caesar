---
title: API Reference

language_tabs: # must be one of https://git.io/vQNgJ
  - http

toc_footers:
  - <a href='https://github.com/zooniverse/caesar/tree/master/docs/source/'>Modify documentation</a>
  - <a href='https://github.com/tripit/slate'>Documentation Powered by Slate</a>

includes:
  - caesar_data
  - reducer_configuration
  - reduction_mode
  - subject_metadata
  - rules
  - how_to_swap
  - errors
  - extracts

search: true
---

# Introduction

This is on the docupdate branch. We are updating this page

Caesar is an evolution of the Nero codebase, which is made more generic. In
essence, Caesar receives classifications from the event stream (a Lambda script
sends them to Caesars HTTP API).

For each classification, it runs zero or more extractors defined in the
workflow to generate "extracts". These extracts specify information summarized
out of the full classification.

Whenever extracts change, Caesar will then run zero or more reducers defined in
the workflow. Each reducer receives all the extracts, merged into one hash per
classification. The task of the reducer is to aggregate results from multiple
classifications into key-value pairs, where values are simple data types:
integers or booleans. The output of each reducer is stored in the database as a
`Reduction`.

Whenever a reduction changes, Caesar will then run zero or more [rules defined
in the
workflow](https://github.com/zooniverse/caesar/blob/master/docs/rules.md). Each
rule is a boolean statement that can look at values produced by reducers (by
key), compare. Rules support logic clauses like `and` / `or` / `not`. When the
rule evaluates to `true`, all of the effects associated with that rule will be
performed. For instance, an effect might be to retire a subject.

```
┏━━━━━━━━━━━━━━━━━━┓
┃     Kinesis      ┃
┗━━━┳━━━━━━━━━━━━━━┛
    │                                                       ┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐
    │                                                         EXTRACTS:
    │   ┌ ─ ─ ─ ─ ─ ─ ─ ─ ┐         ┌──────────────────┐    │                           │
    ├──▶ Classification 1  ────┬───▶│ FlaggedExtractor │──────▶{flagged: true}
    │   └ ─ ─ ─ ─ ─ ─ ─ ─ ┘    │    └──────────────────┘    │                           │
    │                          │    ┌──────────────────┐
    │                          └───▶│ SurveyExtractor  │────┼─▶{raccoon: 1}             │
    │                               └──────────────────┘
    │   ┌ ─ ─ ─ ─ ─ ─ ─ ─ ┐         ┌──────────────────┐    │                           │
    └──▶ Classification 2  ────┬───▶│ FlaggedExtractor │──────▶{flagged: false}
        └ ─ ─ ─ ─ ─ ─ ─ ─ ┘    │    └──────────────────┘    │                           │
                               │    ┌──────────────────┐
                               └───▶│ SurveyExtractor  │────┼─▶{beaver: 1, raccoon: 1}  │
                                    └──────────────────┘
   ┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐                          └ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘
     REDUCTIONS:                                                          │
   │                             │                                        │
      {                                                                   │
   │    votes_flagged: 1,        │  ┌──────────────────┐                  │
        votes_beaver: 1,      ◀─────│ VoteCountReducer │◀─────────────────┘
   │    votes_raccoon: 2         │  └──────────────────┘
      }
   │                             │
                                                                              ┏━━━━━━━━━━━━━━━━┓
   │  {                          │  ┌──────────────────┐                      ┃Some script run ┃
        swap_confidence: 0.23 ◀─────│ ExternalReducer  │◀────HTTP API call────┃by project owner┃
   │  }                          │  └──────────────────┘                      ┃  (externally)  ┃
                                                                              ┗━━━━━━━━━━━━━━━━┛
   └ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘
                  │
                  │
                  │                 ┌──────────────────┐         POST         ┏━━━━━━━━━━━━━━━━┓
                  └────────────────▶│       Rule       │───/subjects/retire──▶┃    Panoptes    ┃
                                    └──────────────────┘                      ┗━━━━━━━━━━━━━━━━┛
```

To make this more concrete, an example would be a survey-task workflow where:

* An extractor emits key-value pairs like `lion=1` when the user tagged a lion
  in the image.
* A reducer combines multiple classifications by adding up the lion counts,
  emitting `lion=5, coyote=1`
* A rule then checks `lion > 4`, which returns true, and therefore Caesar
  retires the image.

Reducers can reduce across multiple subjects' extracts if the following is
included in the new subject's metadata (when uploaded to Panoptes): `{
previous_subject_ids: [1234] }`. Extracts whose subject ids match an id in that
array will be included in reductions for the new subject.

# Usage

Caesar listens to classification events for workflows from the event stream.
You need to let Caesar know to listen to this workflow and it has to be a
workflow you have access to in zooniverse.org.

There are two ways to configure Caesar, manually via the UI or programmatically the API.
E.g. with a Zooniverse.org workflow id = 1234

## Configuring Caesar via the Web UI
 + Visit https://caesar.zooniverse.org/ and login.
 + Click on "Workflows" and click "Add" and enter the workflow ID (you can find this in the Project Builder page)
 + You can use the Extractors and Reducers to configure the extraction and reduction pipeline
 + Use the UI to configure your rules and effects as per the [rules](#rules) & [effects](#effects) docs.

