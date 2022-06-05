# frozen_string_literal: true

# Policy to determine if account can view a album
class PhotoPolicy
  def initialize(account, photo, auth_scope = nil)
    @account = account
    @photo = photo
    @auth_scope = auth_scope
  end

  def can_view?
    can_read? && (account_owns_album? || account_participates_on_album?)
  end

  def can_edit?
    can_write? && (account_owns_album? || account_participates_on_album?)
  end

  def can_delete?
    # the participates should not able to delete the photos in that album
    # || account_collaborates_on_album?
    can_write? && account_owns_album?
  end

  def summary
    {
      can_view: can_view?,
      can_edit: can_edit?,
      can_delete: can_delete?
    }
  end

  private

  def can_read?
    @auth_scope ? @auth_scope.can_read?('photos') : false
  end

  def can_write?
    @auth_scope ? @auth_scope.can_write?('photos') : false
  end

  def account_owns_album?
    @photo.album.owner == @account
  end

  def account_participates_on_album?
    @photo.album.participants.include?(@album)
  end
end
