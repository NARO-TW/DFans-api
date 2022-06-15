# frozen_string_literal: true

module DFans
  # Add a collaborator to another owner's existing album
  class CreatePhoto
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to add more photos'
      end
    end

    # Error for requests with illegal attributes
    class IllegalRequestError < StandardError
      def message
        'Cannot create a photo with those attributes'
      end
    end

    def self.call(auth:, album:, photo_data:)
      policy = AlbumPolicy.new(auth[:account], album, auth[:scope])
      raise ForbiddenError unless policy.can_add_photos?
      puts "In CreatePhoto: policy: #{policy}"
      album.add_photo(photo_data)
      puts "In CreatePhoto: album.add_photo(photo_data): #{album.add_photo(photo_data)}"
    rescue Sequel::MassAssignmentRestriction
      raise IllegalRequestError
    end
  end
end
