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
end
