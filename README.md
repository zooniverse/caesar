# README

Caesar is an evolution of the Nero codebase, which is made more generic. In
essence, Caesar receives classifications from the event stream (a Lambda
script sends them to Caesars HTTP API). 

* [Documentation](https://zooniverse.github.io/caesar)
* [Production](https://caesar.zooniverse.org)
* [Staging](https://caesar-staging.zooniverse.org)

## Development

Prepare the Docker containers:

```
docker-compose build
docker-compose run app bin/rails db:setup
docker-compose run -e RAILS_ENV=test app bin/rails db:create
```

Run tests with:

```
docker-compose run -e RAILS_ENV=test app bin/rspec
```

Start a local server with:

```
docker-compose up
```

To have it listen to the stream:

```
AWS_REGION=us-east-1 kinesis-tail zooniverse-staging | bin/stream_to_server
```

Or to override the configuration for a given workflow, create a local file in `tmp/` (or anywhere else, but that directory is ignored by git) and run:

```
AWS_REGION=us-east-1 kinesis-tail zooniverse-staging | bin/override_workflow_configuration workflow_id tmp/path_to_nero_config.json | bin/stream_to_server
```


## Kinesis / Lambda

Panoptes posts classifications into Kinesis. Caesar has a Lambda script that
reads in from Kinesis and then POSTs those into Caesar's API. Docs on how to
change that lambda script are in the
[kinesis-to-http](https://github.com/zooniverse/caesar/tree/master/kinesis-to-http)
directory.

### Mutation tests

```
RAILS_ENV=test bundle exec mutant -r ./config/environment --use rspec Reducers::ExternalReducer
```
