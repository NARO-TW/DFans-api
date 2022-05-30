# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database
  DFans::Photo.map(&:destroy)
  DFans::Album.map(&:destroy)
  DFans::Account.map(&:destroy)
end

def auth_header(account_data)
  auth = DFans::AuthenticateAccount.call(
    username: account_data['username'],
    password: account_data['password']
  )

  "Bearer #{auth[:attributes][:auth_token]}"
end


DATA = {
  accounts: YAML.load(File.read('app/db/seeds/accounts_seed.yml')),
  photos: YAML.load(File.read('app/db/seeds/photo_seeds.yml')),
  albums: YAML.load(File.read('app/db/seeds/album_seeds.yml'))
}.freeze
