# frozen_string_literal: true

require 'sequel'
require 'json'
require_relative './password'

module DFans
  # Models a registered account
  class Account < Sequel::Model
    one_to_many :owned_albums, class: :'DFans::Album', key: :owner_id
    #many_to_many :collaborations,
    #             class: :'DFans::Album',
    #             join_table: :accounts_albums,
    #             left_key: :collaborator_id, right_key: :album_id

    plugin :association_dependencies,
           owned_albums: :destroy,
    #       collaborations: :nullify

    plugin :whitelist_security
    set_allowed_columns :username, :email, :password

    plugin :timestamps, update_on_create: true

    def albums
      owned_albums + collaborations
    end

    def password=(new_password)
      self.password_digest = Password.digest(new_password)
    end

    def password?(try_password)
      digest = DFans::Password.from_digest(password_digest)
      digest.correct?(try_password)
    end

    def to_json(options = {})
      JSON(
        {
          type: 'account',
          id:,
          username:,
          email:
        }, options
      )
    end
  end
end
