# frozen_string_literal: true

module DFans
    # Policy to determine if an account can view a particular album
  class ParticipationRequestPolicy
    def initialize(album, requestor_account, target_account, auth_scope = nil)
      @album = album
      @requestor_account = requestor_account
      @target_account = target_account
      @auth_scope = auth_scope
      @requestor = AlbumPolicy.new(requestor_account, album, auth_scope)
      @target = AlbumPolicy.new(target_account, album, auth_scope)
    end

    def can_invite?
      can_write? &&
      (@requestor.can_add_participants? && @target.can_participate?)
    end

    def can_remove?
      can_write? &&
      (@requestor.can_remove_participants? && target_is_participant?)
    end

    private

    def can_write?
      @auth_scope ? @auth_scope.can_write?('albums') : false
    end

    def target_is_participant?
      @album.participants.include?(@target_account)
    end
  end
end
