# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Album Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    @account_data = DATA[:accounts][0]
    @wrong_account_data = DATA[:accounts][1]

    @account = DFans::Account.create(@account_data)
    @wrong_account = DFans::Account.create(@wrong_account_data)

    header 'CONTENT_TYPE', 'application/json'
  end

  describe 'Getting albums' do
    describe 'Getting list of albums' do
      before do
        @account.add_owned_album(DATA[:albums][0])
        @account.add_owned_album(DATA[:albums][1])
      end

      it 'HAPPY: should get list for authorized account' do
        header 'AUTHORIZATION', auth_header(@account_data)

        get 'api/v1/albums'
        _(last_response.status).must_equal 200

        result = JSON.parse last_response.body
        _(result['data'].count).must_equal 2
      end

      it 'BAD: should not process without authorization' do
        get 'api/v1/albums'
        _(last_response.status).must_equal 403

        result = JSON.parse last_response.body
        _(result['data']).must_be_nil
      end
    end

    it 'HAPPY: should be able to get details of a single album' do
      album = @account.add_owned_album(DATA[:albums][0])

      header 'AUTHORIZATION', auth_header(@account_data)
      get "/api/v1/albums/#{album.id}"
      _(last_response.status).must_equal 200

      result = JSON.parse(last_response.body)['data']
      _(result['attributes']['id']).must_equal album.id
      _(result['attributes']['name']).must_equal album.name
    end

    it 'SAD: should return error if unknown album requested' do
      header 'AUTHORIZATION', auth_header(@account_data)
      get '/api/v1/albums/foobar'

      _(last_response.status).must_equal 404
    end

    it 'BAD AUTHORIZATION: should not get album with wrong authorization' do
      album = @account.add_owned_album(DATA[:albums][0])

      header 'AUTHORIZATION', auth_header(@wrong_account_data)
      get "/api/v1/albums/#{album.id}"
      _(last_response.status).must_equal 403

      result = JSON.parse last_response.body
      _(result['attributes']).must_be_nil
    end

    it 'BAD SQL VULNERABILTY: should prevent basic SQL injection of id' do
      @account.add_owned_album(DATA[:albums][0])
      @account.add_owned_album(DATA[:albums][1])

      header 'AUTHORIZATION', auth_header(@account_data)
      get 'api/v1/Albums/2%20or%20id%3E0'

      # deliberately not reporting detection -- don't give attacker information
      _(last_response.status).must_equal 404
      _(last_response.body['data']).must_be_nil
    end
  end

  describe 'Creating New Albums' do
    before do
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
      @album_data = DATA[:albums][0]
    end

    it 'HAPPY: should be able to create new albums' do
      post 'api/v1/albums', @pho_data.to_json, @req_header
      header 'AUTHORIZATION', auth_header(@account_data)
      post 'api/v1/albums', @album_data.to_json

      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['attributes']
      pho = DFans::Album.first

      _(created['id']).must_equal pho.id
      _(created['name']).must_equal @pho_data['name']
    end

    it 'SAD: should not create new album without authorization' do
      post 'api/v1/albums', @album_data.to_json

      created = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 403
      _(last_response.header['Location']).must_be_nil
      _(created).must_be_nil
    end

    it 'SECURITY: should not create album with mass assignment' do
      bad_data = @pho_data.clone
      bad_data['created_at'] = '1900-01-01'
      header 'AUTHORIZATION', auth_header(@account_data)
      post 'api/v1/albums', bad_data.to_json

      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
    end
  end
end