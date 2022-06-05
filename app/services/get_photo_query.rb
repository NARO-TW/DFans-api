# frozen_string_literal: true

module DFans
  # Add a collaborator to another owner's existing album
  class GetPhotoQuery
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access that photo'
      end
    end

    # Error for cannot find a album
    class NotFoundError < StandardError
      def message
        'We could not find that photo'
      end
    end

    # Photo for given requestor account
    def self.call(auth:, photo:)
      raise NotFoundError unless photo

      policy = PhotoPolicy.new(auth[:account], photo, auth[:scope])
      raise ForbiddenError unless policy.can_view?

      photo
    end
  end
end
