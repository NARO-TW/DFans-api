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

    @owner_data = DATA[:accounts][0]
    @owner = DFans::Account.all[0]
    @participant = DFans::Account.all[1]
    @album = @owner.add_owned_album(album_data)
  end

  it 'HAPPY: should be able to add a participant to a album' do
    auth = authorization(@owner_data)

    DFans::AddParticipant.call(
      auth:,
      album: @album,
      parti_email: @participant.email
    )
    _(@participant.albums.count).must_equal 1
    _(@participant.albums.first).must_equal @album
  end

  it 'BAD: should not add owner as a participant' do
    auth = DFans::AuthenticateAccount.call(
      username: @owner_data['username'],
      password: @owner_data['password']
    )
    _(proc {
      DFans::AddParticipant.call(
        auth:,
        album: @album,
        parti_email: @owner.email
      )
    }).must_raise DFans::AddParticipant::ForbiddenError
  end
end
