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
    album = DFans::Album.first
    DATA[:photos].each do |pho|
      album.add_photo(pho)
    end

    get "api/v1/albums/#{album.id}/photos"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 2
  end

  it 'HAPPY: should be able to get details of a single photo' do
    pho_data = DATA[:photos][1]
    album = DFans::Album.first
    pho = album.add_photo(pho_data)

    get "/api/v1/albums/#{album.id}/photos/#{pho.id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['id']).must_equal pho.id
    _(result['data']['attributes']['filename']).must_equal pho_data['filename']
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

      created = JSON.parse(last_response.body)['data']['data']['attributes']
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
#       existing_album = DATA[:albums][1]
#       DFans::Album.create(existing_album)
#       id = DFans::Album.first.id

#       get "/api/v1/albums/#{id}"
#       _(last_response.status).must_equal 200

#       result = JSON.parse last_response.body
#       _(result['data']['attributes']['id']).must_equal id
#       _(result['data']['attributes']['name']).must_equal existing_album['name']
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
#       @album_data = DATA[:albums][1]
#     end

#     it 'HAPPY: should be able to create new albums' do
#       post 'api/v1/albums', @album_data.to_json, @req_header
#       _(last_response.status).must_equal 201
#       _(last_response.header['Location'].size).must_be :>, 0

#       created = JSON.parse(last_response.body)['data']['data']['attributes']
#       album = DFans::Album.first

#       _(created['id']).must_equal album.id
#       _(created['name']).must_equal @album_data['name']
#       _(created['repo_url']).must_equal @album_data['repo_url']
#     end

#     it 'SECURITY: should not create album with mass assignment' do
#       bad_data = @album_data.clone
#       bad_data['created_at'] = '1900-01-01'
#       post 'api/v1/albums', bad_data.to_json, @req_header

#       _(last_response.status).must_equal 400
#       _(last_response.header['Location']).must_be_nil
#     end
#   end
# end
