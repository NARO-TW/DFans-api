# frozen_string_literal: true

require_relative '../spec_helper'
# require 'rbnacl'
# require 'sodium'

describe 'Test AddParticipant service' do
  before do
    wipe_database
    DATA[:accounts].each do |account_data|
      DFans::Account.create(account_data)
    end
    album_data = DATA[:albums].first
    @owner = DFans::Account.all[0]
    @participant = DFans::Account.all[1]
    @album = DFans::CreateAlbumForOwner.call(
      owner_id: @owner.id, album_data: album_data
    )
  end

  it 'HAPPY: should be able to add a participant to a album' do
    DFans::AddParticipant.call(
      account: @owner,
      album: @album,
      parti_email: @participant.email
    )
    _(@participant.albums.count).must_equal 1
    _(@participant.albums.first).must_equal @album
  end

  it 'BAD: should not add owner as a participant' do
    _(proc {
      DFans::AddParticipant.call(
        account: @owner,
        album: @album,
        parti_email: @owner.email
      )
    }).must_raise DFans::AddParticipant::ForbiddenError
  end
end
