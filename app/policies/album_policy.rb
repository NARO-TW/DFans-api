# frozen_string_literal: true

module DFans
  # Policy to determine if an account can view a particular album
  class AlbumPolicy
    def initialize(account, album)
      @account = account
      @album = album
    end

    def can_view?
      account_is_owner? || account_is_participator?
    end

    # duplication is ok!
    def can_edit?
      account_is_owner? || account_is_participator?
    end

    def can_delete?
      account_is_owner?
    end

    def can_leave?
      account_is_participator?
    end

    def can_add_photos?
      account_is_owner? || account_is_participator?
    end

    def can_remove_photos?
      account_is_owner? || account_is_participator?
    end

    def can_add_participators?
      account_is_owner?
    end

    def can_remove_participators?
      account_is_owner?
    end

    def can_collaborate?
      !(account_is_owner? or account_is_participator?)
    end

    def summary
      {
        can_view: can_view?,
        can_edit: can_edit?,
        can_delete: can_delete?,
        can_leave: can_leave?,
        can_add_photos: can_add_photos?,
        can_delete_photos: can_remove_photos?,
        can_add_participators: can_add_participators?,
        can_remove_participators: can_remove_participators?,
        can_collaborate: can_participate?
      }
    end

    private

    def account_is_owner?
      @album.owner == @account
    end

    def account_is_participator?
      @album.participators.include?(@account)
    end
  end
end
