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

  it 'HAPPY: should be able to get list of all photos' do
    proj = DFans::Album.first
    DATA[:photos].each do |doc|
      proj.add_document(doc)
    end

    get "api/v1/albums/#{proj.id}/photos"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 2
  end

  it 'HAPPY: should be able to get details of a single photos' do
    doc_data = DATA[:photos][1]
    proj = DFans::Album.first
    doc = proj.add_document(doc_data)

    get "/api/v1/albums/#{proj.id}/photos/#{doc.id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['id']).must_equal doc.id
    _(result['data']['attributes']['filename']).must_equal doc_data['filename']
  end

  it 'SAD: should return error if unknown photo requested' do
    proj = DFans::Album.first
    get "/api/v1/albums/#{proj.id}/photos/foobar"

    _(last_response.status).must_equal 404
  end

  describe 'Creating Photos' do
    before do
      @proj = DFans::Album.first
      @doc_data = DATA[:photos][1]
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
    end

    it 'HAPPY: should be able to create new photos' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      post "api/v1/albums/#{@proj.id}/photos",
           @doc_data.to_json, req_header
      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['data']['attributes']
      doc = DFans::photos.first

      _(created['id']).must_equal doc.id
      _(created['filename']).must_equal @doc_data['filename']
      _(created['description']).must_equal @doc_data['description']
    end

    it 'SECURITY: should not create photos with mass assignment' do
      bad_data = @doc_data.clone
      bad_data['created_at'] = '1900-01-01'
      post "api/v1/albums/#{@proj.id}/photos",
           bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
    end
  end
end
