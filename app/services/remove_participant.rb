# frozen_string_literal: true

module DFans
  # Add a participant to another owner's existing album
  class RemoveParticipant
    # Error for owner cannot be participant
    class ForbiddenError < StandardError
      def message
        'You are not allowed to remove that person'
      end
    end

    def self.call(req_username:, parti_email:, album_id:)
      account = Account.first(username: req_username)
      album = Album.first(id: album_id)
      participant = Account.first(email: parti_email)

      policy = ParticipationRequestPolicy.new(album, account, participant)
      raise ForbiddenError unless policy.can_remove?

      album.remove_participant(participant)
      participant
    end
  end
end
