# frozen_string_literal: true

require 'json'
require 'sequel'

module DFans
  # Models an album
  class Album < Sequel::Model
    many_to_one :owner, class: :'DFans::Account'

    one_to_many :photos
    plugin :association_dependencies, photos: :destroy

    plugin :uuid, field: :id
    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :name, :description

    # Secure getters and setters
    def description
      SecureDB.decrypt(description_secure)
    end

    def description=(plaintext)
      self.description_secure = SecureDB.encrypt(plaintext)
    end

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'album',
            attributes: {
              id: id,
              name: name
              # tags: tags
            }
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
