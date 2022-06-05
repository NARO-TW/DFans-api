# frozen_string_literal: true

module DFans
  # Service object to create a new Album for an owner
  class CreateAlbumForOwner
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to create albums'
      end
    end

    def self.call(auth:, album_data:)
      raise ForbiddenError unless auth[:scope].can_write?('albums')

      auth[:account].add_owned_album(album_data)    
    end
  end
end
