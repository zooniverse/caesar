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

Welcome to the Caesar API!

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
