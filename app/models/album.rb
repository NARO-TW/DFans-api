# frozen_string_literal: true

require 'json'
require 'sequel'

module DFans
  # Models a project
  class Album < Sequel::Model
    one_to_many :photos
    plugin :association_dependencies, photos: :destroy

    plugin :timestamps

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'album',
            attributes: {
              id: id,
              name: name,
              #tags: tags
            }
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
