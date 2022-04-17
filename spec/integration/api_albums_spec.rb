# frozen_string_literal: true

require_relative '../spec_helper'

# 20220417
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

    get "api/v1/ablums/#{proj.id}/photos"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 2
  end

  it 'HAPPY: should be able to get details of a single photo' do
    doc_data = DATA[:photos][1]
    proj = DFans::Album.first
    doc = proj.add_document(doc_data)

    get "/api/v1/album/#{proj.id}/photos/#{doc.id}"
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
      doc = DFans::Photo.first

      _(created['id']).must_equal doc.id
      _(created['filename']).must_equal @doc_data['filename']
      _(created['description']).must_equal @doc_data['description']
    end

    it 'SECURITY: should not create documents with mass assignment' do
      bad_data = @doc_data.clone
      bad_data['created_at'] = '1900-01-01'
      post "api/v1/albums/#{@proj.id}/photos",
           bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
    end
  end
end

# 20220408
# require_relative '../spec_helper'

# describe 'Test Album Handling' do
#   include Rack::Test::Methods

#   before do
#     wipe_database
#   end

#   describe 'Getting Albums' do
#     it 'HAPPY: should be able to get list of all albums' do
#       DFans::Album.create(DATA[:albums][0])
#       DFans::Album.create(DATA[:albums][1])

#       get 'api/v1/albums'
#       _(last_response.status).must_equal 200

#       result = JSON.parse last_response.body
#       _(result['data'].count).must_equal 2
#     end

#     it 'HAPPY: should be able to get details of a single album' do
#       existing_proj = DATA[:albums][1]
#       DFans::Album.create(existing_proj)
#       id = DFans::Album.first.id

#       get "/api/v1/albums/#{id}"
#       _(last_response.status).must_equal 200

#       result = JSON.parse last_response.body
#       _(result['data']['attributes']['id']).must_equal id
#       _(result['data']['attributes']['name']).must_equal existing_proj['name']
#     end

#     it 'SAD: should return error if unknown album requested' do
#       get '/api/v1/albums/foobar'

#       _(last_response.status).must_equal 404
#     end

#     it 'SECURITY: should prevent basic SQL injection targeting IDs' do
#       DFans::Album.create(name: 'New Album')
#       DFans::Album.create(name: 'Newer Album')
#       get 'api/v1/albums/2%20or%20id%3E0'

#       # deliberately not reporting error -- don't give attacker information
#       _(last_response.status).must_equal 404
#       _(last_response.body['data']).must_be_nil
#     end
#   end

#   describe 'Creating New Albums' do
#     before do
#       @req_header = { 'CONTENT_TYPE' => 'application/json' }
#       @proj_data = DATA[:albums][1]
#     end

#     it 'HAPPY: should be able to create new albums' do
#       post 'api/v1/albums', @proj_data.to_json, @req_header
#       _(last_response.status).must_equal 201
#       _(last_response.header['Location'].size).must_be :>, 0

#       created = JSON.parse(last_response.body)['data']['data']['attributes']
#       proj = DFans::Album.first

#       _(created['id']).must_equal proj.id
#       _(created['name']).must_equal @proj_data['name']
#       _(created['repo_url']).must_equal @proj_data['repo_url']
#     end

#     it 'SECURITY: should not create album with mass assignment' do
#       bad_data = @proj_data.clone
#       bad_data['created_at'] = '1900-01-01'
#       post 'api/v1/albums', bad_data.to_json, @req_header

#       _(last_response.status).must_equal 400
#       _(last_response.header['Location']).must_be_nil
#     end
#   end
# end