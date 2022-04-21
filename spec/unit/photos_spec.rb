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
    doc_data = DATA[:photos][1]
    proj = DFans::Album.first
    new_doc = proj.add_photo(doc_data)

    doc = DFans::Photo.find(id: new_doc.id)
    _(doc.filename).must_equal doc_data['filename']
    _(doc.relative_path).must_equal doc_data['relative_path']
    _(doc.description).must_equal doc_data['description']
    _(doc.content).must_equal doc_data['content']
  end

  it 'SECURITY: should not use deterministic integers' do
    doc_data = DATA[:photos][1]
    proj = DFans::Album.first
    new_doc = proj.add_photo(doc_data)

    _(new_doc.id.is_a?(Numeric)).must_equal false
  end

  it 'SECURITY: should secure sensitive attributes' do
    doc_data = DATA[:photos][1]
    proj = DFans::Album.first
    new_doc = proj.add_photo(doc_data)
    stored_doc = app.DB[:photos].first

    _(stored_doc[:description_secure]).wont_equal new_doc.description
    _(stored_doc[:content_secure]).wont_equal new_doc.content
  end

  it 'SECURITY: should secure sensitive attributes' do
    doc_data = DATA[:photos][1]
    proj = DFans::Album.first
    new_doc = proj.add_photo(doc_data)
    stored_doc = app.DB[:photos].first

    _(stored_doc[:description_secure]).wont_equal new_doc.description
  end

  # it 'HAPPY: should be able to get list of all photos' do
  #   proj = DFans::Album.first
  #   DATA[:photos].each do |doc|
  #     proj.add_photo(doc)
  #     # the attribute 'add_photo' come from?
  #     # why not add_photos?
  #   end

  #   get "api/v1/albums/#{proj.id}/photos"
  #   _(last_response.status).must_equal 200

  #   result = JSON.parse last_response.body
  #   _(result['data'].count).must_equal 2
  # end

  # it 'HAPPY: should be able to get details of a single photo' do
  #   doc_data = DATA[:photos][1]
  #   proj = DFans::Album.first
  #   doc = proj.add_photo(doc_data).save

  #   get "/api/v1/albums/#{proj.id}/photos/#{doc.id}"
  #   _(last_response.status).must_equal 200

  #   result = JSON.parse last_response.body
  #   _(result['data']['attributes']['id']).must_equal doc.id
  #   _(result['data']['attributes']['filename']).must_equal doc_data['filename']
  # end

  # it 'SAD: should return error if unknown photos requested' do
  #   proj = DFans::Album.first
  #   get "/api/v1/albums/#{proj.id}/photos/foobar"

  #   _(last_response.status).must_equal 404
  # end

  # it 'HAPPY: should be able to create new photos' do
  #   proj = DFans::Album.first
  #   doc_data = DATA[:photos][1]

  #   req_header = { 'CONTENT_TYPE' => 'application/json' }
  #   post "api/v1/albums/#{proj.id}/photos",
  #        doc_data.to_json, req_header
  #   _(last_response.status).must_equal 201
  #   _(last_response.header['Location'].size).must_be :>, 0

  #   created = JSON.parse(last_response.body)['data']['data']['attributes']
  #   doc = DFans::Album.first

  #   _(created['id']).must_equal doc.id
  #   _(created['filename']).must_equal doc_data['filename']
  #   _(created['description']).must_equal doc_data['description']
  # end
end
