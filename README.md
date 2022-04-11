# DFans API

API to store,retrieve, and share confidential photos to unspecific users.

## Routes

All routes return Json

- GET `/`: Root route shows if Web API is running
- GET `api/v1/photos/`: returns all confiugration IDs
- GET `api/v1/photos/[ID]`: returns details about a single photo with given ID
- POST `api/v1/photos/`: upload a new photo

## Install

Install this API by cloning the *relevant branch* and installing required gems from `Gemfile.lock`:

```shell
bundle install
```

## Test

Run the test script:

```shell
bundle exec ruby spec/api_spec.rb
```

## Execute

Run this API using:

```shell
rackup
```
