# frozen_string_literal: true

module DFans
  # Add a participant to another owner's existing album
  class GetAlbumQuery
    # Error for owner cannot be participant
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access that album'
      end
    end

    # Error for cannot find a album
    class NotFoundError < StandardError
      def message
        'We could not find that album'
      end
    end

    def self.call(account:, album:)
      raise NotFoundError unless album

      policy = AlbumPolicy.new(account, album)
      raise ForbiddenError unless policy.can_view?

      album.full_details.merge(policies: policy.summary)
    end
  end
end
