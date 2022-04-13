# frozen_string_literal: true

require 'json'
require 'sequel'

module DFans
  # Models a secret document
  class Photo < Sequel::Model
    many_to_one :album

    plugin :timestamps

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'photo',
            attributes: {
              id:,
              filename:,
              relative_path:,
              description:
            }
          },
          included: {
            album:
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
