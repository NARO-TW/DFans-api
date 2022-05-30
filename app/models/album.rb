# frozen_string_literal: true

require 'json'
require 'sequel'

module DFans
  # Models an album
  class Album < Sequel::Model
    many_to_one :owner, class: :'DFans::Account'

    many_to_many :participants,
                 class: :'DFans::Account',
                 join_table: :accounts_albums,
                 left_key: :album_id, right_key: :participant_id

    one_to_many :photos

    plugin :association_dependencies,
           photos: :destroy,
           participants: :nullify

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
    def to_h
      {
        type: 'album',
        attributes: {
          id:,
          name:,
          description:
        }
      }
    end

    def full_details
      to_h.merge(
        relationships: {
          owner:,
          participants:,
          photos:
        }
      )
    end

    def to_json(options = {})
      JSON(to_h, options)
    end
  end
end