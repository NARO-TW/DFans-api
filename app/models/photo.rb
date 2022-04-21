# frozen_string_literal: true

require 'json'
require 'sequel'

module DFans
  # Models a secret document
  class Photo < Sequel::Model
    many_to_one :album

    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :filename, :relative_path, :description

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'photo',
            attributes: {
              id: @id,
              filename: @filename,
              relative_path: @relative_path,
              description: @description
            }
          },
          included: {
            album: @album
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
