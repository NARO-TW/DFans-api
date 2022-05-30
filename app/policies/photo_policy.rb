# frozen_string_literal: true

# Policy to determine if account can view a album
class PhotoPolicy
  def initialize(account, photo)
    @account = account
    @photo = photo
  end
  
  def can_view?
    account_owns_album? || account_participates_on_album?
  end
  
  def can_edit?
    account_owns_album? || account_participates_on_album?
  end
  
  def can_delete?
    account_owns_album? #|| account_participates_on_album?
    # the participates should not able to delete the photos in that album
  end
  
  def summary
    {
      can_view: can_view?,
      can_edit: can_edit?,
      can_delete: can_delete?
    }
  end
  
  private
  
  def account_owns_album?
    @photo.album.owner == @account
  end
  
  def account_participants_on_ablum?
    @photo.album.participants.include?(@album)
  end
end
