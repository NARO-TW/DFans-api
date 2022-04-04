# frozen_string_literal: true

require 'json'
require 'base64'
require 'rbnacl'

module Dfans
  STORE_DIR = 'app/db/store'

  # Holds a full secret photo
  class Photo
    # Create a new photo by passing in hash of attributes
    def initialize(new_photo)
      @id          = new_photo['id'] || new_id
      @filename    = new_photo['filename']
      @description = new_photo['description']
    end

    attr_reader :id, :filename, :description

    def to_json(options = {})
      JSON(
        {
          type: 'photo',
          id: @id,
          filename: @filename,
          description: @description
        },
        options
      )
    end

    # File store must be setup once when application runs
    def self.setup
      Dir.mkdir(Dfans::STORE_DIR) unless Dir.exist? Dfans::STORE_DIR
    end

    # Stores photo in file store
    def save
      File.write("#{Dfans::STORE_DIR}/#{@id}.txt", to_json)
    end

    # Query method to find one photo
    def self.find(find_id)
      photo_file = File.read("#{Dfans::STORE_DIR}/#{find_id}.txt")
      Photo.new JSON.parse(photo_file)
    end

    # Query method to retrieve index of all photos
    def self.all
      Dir.glob("#{Dfans::STORE_DIR}/*.txt").map do |file|
        file.match(%r{#{Regexp.quote(Dfans::STORE_DIR)}/(.*)\.txt})[1]
      end
    end

    private

    def new_id
      timestamp = Time.now.to_f.to_s
      Base64.urlsafe_encode64(RbNaCl::Hash.sha256(timestamp))[0..9]
    end
  end
end
