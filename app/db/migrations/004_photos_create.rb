# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:photos) do
      primary_key :id
      foreign_key :album_id, table: :albums

      String :filename, null: false
      String :enc_type, null: false
      String :image_data_secure, null: false
      String :description_secure
      String :filetype

      # text type: https://github.com/jeremyevans/sequel/blob/master/doc/schema_modification.rdoc

      DateTime :created_at
      DateTime :updated_at

      unique [:album_id, :filename]
    end
  end
end
