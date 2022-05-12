# frozen_string_literal: true

module DFans
  # Service object to create a new Album for an owner
  class CreateAlbumForOwner
    def self.call(owner_id:, album_data:)
      Account.find(id: owner_id)
             .add_owned_album(album_data)
    end
  end
end
