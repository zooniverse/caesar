# README


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

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:


* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
