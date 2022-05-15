# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:photos) do
      primary_key :id
      foreign_key :album_id, table: :albums

      String :filename, null: false
      String :description_secure

      DateTime :created_at
      DateTime :updated_at

      unique [:album_id, :filename]
    end
  end
end
