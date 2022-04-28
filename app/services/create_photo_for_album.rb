# frozen_string_literal: true

module DFans
  # Create new configuration for a album
  class CreatePhotoForAlbum
    def self.call(album_id:, photo_data:)
      Album.first(id: album_id).add_photo(photo_data)
    end
  end
end
