# frozen_string_literal: true

require_relative './spec_helper'

describe 'Getting Photo' do
  before do
    @alb = DFans::Album.first
    DATA[:photos].each do |doc_data|
        DFans::CreatePhotoForAlbum.all(
            album_id: @alb.id,
            photo_data:pho_data # 不確定
        )
    end
  end
end