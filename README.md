# DFans API

API to store,retrieve, and share confidential photos to unspecific users.

## Routes

All routes return Json

- GET  `/`: Root route shows if Web API is running
- GET  `api/v1/accounts/[username]`: Get account details
- POST `api/v1/accounts`: Create a new account
- GET  `api/v1/albums/[album_id]/photos/[photo_id]`: Get a photo in an album
- GET  `api/v1/albums/[album_id]/photos`: Get the list of photos for an album
- POST `api/v1/albums/[album_id]/photos`: Upload photos for an album
- GET  `api/v1/albums/[album_id]`: Get information about an album
- GET  `api/v1/albums`: Get list of all albums
- POST `api/v1/albums`: Create a new album

## Install

Install this API by cloning the *relevant branch* and use bundler to install specified gems from `Gemfile.lock`:

```shell
bundle install
```

Setup development database once:

```shell
rake db:migrate
```

## Test

Setup test database once:

```shell
RACK_ENV=test rake db:migrate
```

Run the test specification script in `Rakefile`:

```shell
rake spec
```

## Develop/Debug

Add fake data to the development database to work on this project:

```shell
rake db:seed
```

## Execute

Launch the API using:

```shell
rake run:dev
```

## Release check

Before submitting pull requests, please check if specs, style, and dependency audits pass (will need to be online to update dependency database):

```shell
rake release?
```