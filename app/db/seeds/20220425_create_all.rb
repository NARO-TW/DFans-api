# frozen_string_literal: true

require './app/controllers/helpers'
include DFans::SecureRequestHelpers

Sequel.seed(:development) do
  def run
    puts 'Seeding accounts, albums, photos'
    create_accounts
    create_owned_albums
    create_photos
  end
end

require 'yaml'
DIR = File.dirname(__FILE__)
ACCOUNTS_INFO = YAML.load_file("#{DIR}/accounts_seed.yml")
OWNER_INFO = YAML.load_file("#{DIR}/owners_albums.yml")
ALBUM_INFO = YAML.load_file("#{DIR}/album_seeds.yml")
PHOTO_INFO = YAML.load_file("#{DIR}/photo_seeds.yml")
# PARTI_INFO = YAML.load_file("#{DIR}/albums_participants.yml")

def create_accounts
  ACCOUNTS_INFO.each do |account_info|
    DFans::Account.create(account_info)
  end
end

def create_owned_albums
  OWNER_INFO.each do |owner|
    account = DFans::Account.first(username: owner['username'])
    owner['album_name'].each do |album_name|
      album_data = ALBUM_INFO.find { |album| album['name'] == album_name }
      account.add_owned_album(album_data)
    end
  end
end

def create_photos
  pho_info_each = PHOTO_INFO.each
  albums_cycle = DFans::Album.all.cycle
  loop do
    pho_info = pho_info_each.next
    album = albums_cycle.next
    # auth_token = AuthToken.create(album.owner)
    # auth = scoped_auth(auth_token)
    auth = scoped_auth(AuthToken.create(album.owner))
    DFans::CreatePhoto.call(
      auth:, album:, photo_data: pho_info
    )
  end
end

def add_participants
  parti_info = PARTI_INFO
  parti_info.each do |parti|
    album = DFans::Album.first(name: parti['album_name'])
    auth_token = AuthToken.create(album.owner)
    auth = scoped_auth(auth_token)
    parti['participant_email'].each do |email|
      # account = album.owner
      DFans::AddParticipant.call(auth:, album:, parti_email: email)
    end
  end
end
