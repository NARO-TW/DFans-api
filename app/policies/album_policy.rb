# frozen_string_literal: true

module DFans
  # Policy to determine if an account can view a particular album
  class AlbumPolicy
    def initialize(account, album, auth_scope = nil)
      @account = account
      @album = album
      @auth_scope = auth_scope
    end

    def can_view?
      can_read? && (account_is_owner? || account_is_participant?)
    end

    # duplication is ok!
    def can_edit?
      can_write? && (account_is_owner? || account_is_participant?)
    end

    def can_delete?
      can_write? && account_is_owner?
    end

    def can_leave?
      account_is_participant?
    end

    def can_add_photos?
      can_write? && (account_is_owner? || account_is_participant?)
    end

    def can_remove_photos?
      can_write? && (account_is_owner? || account_is_participant?)
    end

    def can_add_participants?
      can_write? && account_is_owner?
    end

    def can_remove_participants?
      can_write? && account_is_owner?
    end

    def can_collaborate?
      !(account_is_owner? || account_is_participant?)
    end

    def summary # rubocop:disable Metrics/MethodLength
      {
        can_view: can_view?,
        can_edit: can_edit?,
        can_delete: can_delete?,
        can_leave: can_leave?,
        can_add_photos: can_add_photos?,
        can_delete_photos: can_remove_photos?,
        can_add_participants: can_add_participants?,
        can_remove_participants: can_remove_participants?,
        can_participate: can_participate?
      }
    end

    private

    def can_read?
      @auth_scope ? @auth_scope.can_read?('albums') : false
    end

    def can_write?
      @auth_scope ? @auth_scope.can_write?('albums') : false
    end

    def account_is_owner?
      @album.owner == @account
    end

    def account_is_participant?
      @album.participants.include?(@account)
    end
  end
end
