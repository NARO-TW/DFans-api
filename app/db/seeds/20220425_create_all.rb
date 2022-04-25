# frozen_string_literal: true

Sequel.seed(:development) do
  def run
    puts 'Seeding accounts, albums, photos'
    create_accounts
    create_owned_albums
    create_photos
#    add_collaborators
  end
end

require 'yaml'
DIR = File.dirname(__FILE__)
ACCOUNTS_INFO = YAML.load_file("#{DIR}/accounts_seed.yml")
OWNER_INFO = YAML.load_file("#{DIR}/owners_albums.yml")
ALBUM_INFO = YAML.load_file("#{DIR}/album_seeds.yml")
PHOTO_INFO = YAML.load_file("#{DIR}/photo_seeds.yml")
#CONTRIB_INFO = YAML.load_file("#{DIR}/albums_collaborators.yml")

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
#      DFans::CreateAlbumForOwner.call(
#        owner_id: account.id, album_data: album_data
#      )
    end
  end
end

def create_photos
  pho_info_each = PHOTO_INFO.each
  albums_cycle = DFans::Album.all.cycle
  loop do
    pho_info = pho_info_each.next
    album = albums_cycle.next
#    DFans::CreatePhotoForAlbum.call(
#      album_id: album.id, photo_data: pho_info
#    )
  end
end

#def add_collaborators
#  contrib_info = CONTRIB_INFO
#  contrib_info.each do |contrib|
#    album = DFans::Album.first(name: contrib['album_name'])
#    contrib['collaborator_email'].each do |email|
#      DFans::AddCollaboratorToAlbum.call(
#        email:, album_id: album.id
#      )
#    end
#  end
#end
