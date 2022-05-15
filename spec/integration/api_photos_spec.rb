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

  it 'HAPPY: should be able to get the list of all photos from a single album' do
    album = DFans::Album.first
    DATA[:photos].each do |pho|
      album.add_photo(pho)
    end

    get "api/v1/albums/#{album.id}/photos"
    _(last_response.status).must_equal 200

    result = JSON.parse(last_response.body)['data']
    _(result.count).must_equal 2
    result.each do |pho|
      _(pho['type']).must_equal 'photo'
    end
  end

  it 'HAPPY: should be able to get details of a single photo' do
    pho_data = DATA[:photos][1]
    album = DFans::Album.first
    pho = album.add_photo(pho_data)

    get "/api/v1/albums/#{album.id}/photos/#{pho.id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['attributes']['id']).must_equal pho.id
    _(result['attributes']['filename']).must_equal pho_data['filename']
  end

  it 'SAD: should return error if unknown photo requested' do
    album = DFans::Album.first
    get "/api/v1/albums/#{album.id}/photos/foobar"

    _(last_response.status).must_equal 404
  end

  describe 'Creating Photos' do
    before do
      @album = DFans::Album.first
      @pho_data = DATA[:photos][1]
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
    end

    it 'HAPPY: should be able to create new photos' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      post "api/v1/albums/#{@album.id}/photos",
           @pho_data.to_json, req_header
      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['attributes']
      pho = DFans::Photo.first

      _(created['id']).must_equal pho.id
      _(created['filename']).must_equal @pho_data['filename']
      _(created['description']).must_equal @pho_data['description']
    end

    it 'SECURITY: should not create photos with mass assignment' do
      bad_data = @pho_data.clone
      bad_data['created_at'] = '1900-01-01'
      post "api/v1/albums/#{@album.id}/photos",
           bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
    end
  end
end