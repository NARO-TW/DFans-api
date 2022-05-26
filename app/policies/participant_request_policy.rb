# frozen_string_literal: true

module DFans
    # Policy to determine if an account can view a particular album
  class ParticipationRequestPolicy
    def initialize(album, requestor_account, target_account)
      @Album = Album
      @requestor_account = requestor_account
      @target_account = target_account
      @requestor = AlbumPolicy.new(requestor_account, album)
      @target = AlbumPolicy.new(target_account, album)
    end
  
    def can_invite?
      @requestor.can_add_participants? && @target.can_participant?
    end
  
    def can_remove?
      @requestor.can_remove_participants? && target_is_participant?
    end
  
    private
  
    def target_is_participant?
      @album.participants.include?(@target_account)
    end
  end
end
