# frozen_string_literal: true

module DFans
  # Add a participant to another owner's existing album
  class AddParticipant
    # Error for owner cannot be participant
    class ForbiddenError < StandardError
      def message
        'You are not allowed to invite that person as participant'
      end
    end

    def self.call(auth:, album:, parti_email:)
      invitee = Account.first(email: parti_email)
      policy = ParticipationRequestPolicy.new(
        album, auth[:account], invitee, auth[:scope]
      )
      raise ForbiddenError unless policy.can_invite?

      album.add_participant(invitee)
      invitee
    end
  end
end
