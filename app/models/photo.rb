# frozen_string_literal: true

require 'json'
require 'sequel'

module DFans
  # Models a secret photo
  class Photo < Sequel::Model

    many_to_one :album

    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :filename, :filetype, :image_data, :description

    # Secure getters and setters
    def description
      SecureDB.decrypt(description_secure)
    end

    def description=(plaintext)
      self.description_secure = SecureDB.encrypt(plaintext)
    end

    def image_data
      SecureDB.decrypt(image_data_secure)
    end

    def image_data=(plaintext)
      self.image_data_secure = SecureDB.encrypt(plaintext)
    end

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          type: 'photo',
          attributes: {
            id: id,
            filename: filename,
            description: description,
            filetype: filetype,
            image_data: image_data
          },
          include: {
            album: album
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
