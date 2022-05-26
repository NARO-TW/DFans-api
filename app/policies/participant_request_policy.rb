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
      @requestor.can_add_participators? && @target.can_participator?
    end
  
    def can_remove?
      @requestor.can_remove_participators? && target_is_participator?
    end
  
    private
  
    def target_is_participator?
      @album.participators.include?(@target_account)
    end
  end
end
