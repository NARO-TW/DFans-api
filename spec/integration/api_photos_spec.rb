# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Photo Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    @account_data = DATA[:accounts][0]
    @wrong_account_data = DATA[:accounts][1]

    @account = DFans::Account.create(@account_data)
    @account.add_owned_album(DATA[:albums][0])
    @account.add_owned_album(DATA[:albums][1])
    DFans::Account.create(@wrong_account_data)

    header 'CONTENT_TYPE', 'application/json'
  end

  describe 'Getting a single photo' do
    it 'HAPPY: should be able to get details of a single photo' do
      pho_data = DATA[:photos][0]
      album = @account.albums.first
      pho = album.add_photo(pho_data)

      header 'AUTHORIZATION', auth_header(@account_data)
      get "/api/v1/photos/#{pho.id}"
      _(last_response.status).must_equal 200

      result = JSON.parse(last_response.body)['data']
      _(result['attributes']['id']).must_equal pho.id
      _(result['attributes']['filename']).must_equal pho_data['filename']
    end

    it 'SAD AUTHORIZATION: should not get details without authorization' do
      pho_data = DATA[:photos][1]
      album = DFans::Album.first
      pho = album.add_photo(pho_data)

      get "/api/v1/photos/#{pho.id}"

      result = JSON.parse last_response.body

      _(last_response.status).must_equal 403
      _(result['attributes']).must_be_nil
    end
  end

  it 'BAD AUTHORIZATION: should not get details with wrong authorization' do
    pho_data = DATA[:photos][0]
    album = @account.albums.first
    pho = album.add_photo(pho_data)

    header 'AUTHORIZATION', auth_header(@wrong_account_data)
    get "/api/v1/photos/#{pho.id}"
    result = JSON.parse last_response.body

    _(last_response.status).must_equal 403
    _(result['attributes']).must_be_nil
  end

  it 'SAD: should return error if photo does not exist' do
    header 'AUTHORIZATION', auth_header(@account_data)
    get '/api/v1/photos/foobar'

    _(last_response.status).must_equal 404
  end

  describe 'Creating Photos' do
    before do
      @album = DFans::Album.first
      @pho_data = DATA[:photos][1]
    end

    it 'HAPPY: should be able to create when everything correct' do
      header 'AUTHORIZATION', auth_header(@account_data)
      post "api/v1/albums/#{@album.id}/photos", @pho_data.to_json
      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['attributes']
      pho = DFans::Photo.first

      _(created['id']).must_equal pho.id
      _(created['filename']).must_equal @pho_data['filename']
      _(created['description']).must_equal @pho_data['description']
    end

    it 'BAD AUTHORIZATION: should not create with incorrect authorization' do
      header 'AUTHORIZATION', auth_header(@wrong_account_data)
      post "api/v1/albums/#{@album.id}/photos", @pho_data.to_json

      data = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 403
      _(last_response.header['Location']).must_be_nil
      _(data).must_be_nil
    end

    it 'SAD AUTHORIZATION: should not create without any authorization' do
      post "api/v1/albums/#{@album.id}/photos", @pho_data.to_json

      data = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 403
      _(last_response.header['Location']).must_be_nil
      _(data).must_be_nil
    end

    it 'BAD VULNERABILITY: should not create with mass assignment' do
      bad_data = @pho_data.clone
      bad_data['created_at'] = '1900-01-01'
      header 'AUTHORIZATION', auth_header(@account_data)
      post "api/v1/albums/#{@album.id}/photos", bad_data.to_json

      data = JSON.parse(last_response.body)['data']
      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
      _(data).must_be_nil
    end
  end
end
