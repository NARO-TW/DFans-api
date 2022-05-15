# frozen_string_literal: true

module DFans
  # Add a Participant to another owner's existing project
  class AddParticipantToAlbum
    # Error for owner cannot be collaborator
    class OwnerNotParticipantError < StandardError
      def message = 'Owner cannot be participant of album'
    end

    def self.call(email:, album_id:)
      participant = Account.first(email:) # Find the account with  the email provided
      album = Album.first(id: album_id) # Find the album with  the album_id
      # Check the participant is not the album owner. If 'True', raise the exception "OwnerNotParticipantError".
      raise(OwnerNotParticipantError) if album.owner.id == participant.id

      album.add_participant(participant)
    end
  end
end
