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
    alb = DFans::Album.first
    new_pho = alb.add_photo(pho_data)

    pho = DFans::Photo.find(id: new_pho.id)
    _(pho.filename).must_equal pho_data['filename']
    _(pho.description).must_equal pho_data['description']
  end

  # (deterministic integers for IDs) We are not using uuid, so no point to test non-deterministic IDs

  # it 'SECURITY: should not use deterministic integers' do
  #   pho_data = DATA[:photos][1]
  #   alb = DFans::Album.first
  #   new_pho = alb.add_photo(pho_data)
  #   _(new_pho.id.is_a?(Numeric)).must_equal false
  # end

  it 'SECURITY: should secure sensitive attributes' do
    pho_data = DATA[:photos][1]
    alb = DFans::Album.first
    new_pho = alb.add_photo(pho_data)
    stored_pho = app.DB[:photos].first

    _(stored_pho[:description_secure]).wont_equal new_pho.description
    _(stored_pho[:content_secure]).wont_equal new_pho.description
  end
end
