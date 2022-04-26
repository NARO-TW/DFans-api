# frozen_string_literal: true

describe 'Getting Photo' do
  before do
    @alb = DFans::Album.first
    DATA[:photos].each do |doc_data|
        DFans::CreatePhotoForAlbum.all(
            album_id: @alb.id
            photo_data:pho_data # 不確定
        )
    end
  end
  