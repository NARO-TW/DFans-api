# frozen_string_literal: true

require_relative './spec_helper'

describe 'Test Album Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
  end

  it 'HAPPY: should be able to get list of all albums' do
    DFans::Album.create(DATA[:albums][0]).save
    DFans::Album.create(DATA[:albums][1]).save

    get 'api/v1/albums'
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 2
  end

  it 'HAPPY: should be able to get details of a single album' do
    existing_album = DATA[:albums][1]
    DFans::Album.create(existing_album).save
    id = DFans::Album.first.id

    get "/api/v1/albums/#{id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['id']).must_equal id
    _(result['data']['attributes']['name']).must_equal existing_album['name']
  end

  it 'SAD: should return error if unknown album requested' do
    get '/api/v1/albums/foobar'

    _(last_response.status).must_equal 404
  end

  it 'HAPPY: should be able to create new albums' do
    existing_album = DATA[:albums][1]

    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post 'api/v1/albums', existing_album.to_json, req_header
    _(last_response.status).must_equal 201
    _(last_response.header['Location'].size).must_be :>, 0

    created = JSON.parse(last_response.body)['data']['data']['attributes']
    album = DFans::Album.first

    _(created['id']).must_equal album.id
    _(created['name']).must_equal existing_album['name']
  end
end
