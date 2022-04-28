module DFans
  # Service object to create a new project for an owner
  class CreateAlbumForOwner
    def self.call(owner_id:, album_data:)
      Account.find(id: owner_id)
             .add_owned_project(album_data)
    end
  end
end