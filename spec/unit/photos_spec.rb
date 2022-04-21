# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Photo Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    DATA[:albums].each do |album_data|
      DFans::Album.create(album_data)
    end
  end

  it 'HAPPY: should retrieve correct data from database' do
    pho_data = DATA[:photos][1]
    album = DFans::Album.first
    new_pho = album.add_photo(pho_data)

    pho = DFans::Photo.find(id: new_pho.id)
    _(pho.filename).must_equal pho_data['filename']
    _(pho.relative_path).must_equal pho_data['relative_path']
    _(pho.description).must_equal pho_data['description']
  end

  it 'SECURITY: should secure sensitive attributes' do
    pho_data = DATA[:photos][1]
    album = DFans::Album.first
    new_pho = album.add_photo(pho_data)
    stored_pho = app.DB[:photos].first

    _(stored_pho[:description_secure]).wont_equal new_pho.description
  end

  it 'SECURITY: should secure sensitive attributes' do
    pho_data = DATA[:photos][1]
    album = DFans::Album.first
    new_pho = album.add_photo(pho_data)
    stored_pho = app.DB[:photos].first

    _(stored_pho[:description_secure]).wont_equal new_pho.description
  end

  # it 'HAPPY: should be able to get list of all photos' do
  #   album = DFans::Album.first
  #   DATA[:photos].each do |pho|
  #     album.add_photo(pho)
  #     # the attribute 'add_photo' come from?
  #     # why not add_photos?
  #   end

  #   get "api/v1/albums/#{album.id}/photos"
  #   _(last_response.status).must_equal 200

  #   result = JSON.parse last_response.body
  #   _(result['data'].count).must_equal 2
  # end

  # it 'HAPPY: should be able to get details of a single photo' do
  #   pho_data = DATA[:photos][1]
  #   album = DFans::Album.first
  #   pho = album.add_photo(pho_data).save

  #   get "/api/v1/albums/#{album.id}/photos/#{pho.id}"
  #   _(last_response.status).must_equal 200

  #   result = JSON.parse last_response.body
  #   _(result['data']['attributes']['id']).must_equal pho.id
  #   _(result['data']['attributes']['filename']).must_equal pho_data['filename']
  # end

  # it 'SAD: should return error if unknown photos requested' do
  #   album = DFans::Album.first
  #   get "/api/v1/albums/#{album.id}/photos/foobar"

  #   _(last_response.status).must_equal 404
  # end

  # it 'HAPPY: should be able to create new photos' do
  #   album = DFans::Album.first
  #   pho_data = DATA[:photos][1]

  #   req_header = { 'CONTENT_TYPE' => 'application/json' }
  #   post "api/v1/albums/#{album.id}/photos",
  #        pho_data.to_json, req_header
  #   _(last_response.status).must_equal 201
  #   _(last_response.header['Location'].size).must_be :>, 0

  #   created = JSON.parse(last_response.body)['data']['data']['attributes']
  #   pho = DFans::Album.first

  #   _(created['id']).must_equal pho.id
  #   _(created['filename']).must_equal pho_data['filename']
  #   _(created['description']).must_equal pho_data['description']
  # end
end
