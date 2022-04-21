# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database
  app.DB[:photos].delete
  app.DB[:albums].delete
end

DATA = {} # rubocop:disable Style/MutableConstant
DATA[:photos] = YAML.safe_load File.read('app/db/seeds/photo_seeds.yml')
DATA[:albums] = YAML.safe_load File.read('app/db/seeds/album_seeds.yml')
