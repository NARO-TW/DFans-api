# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:photos) do
      primary_key :id
      foreign_key :album_id, table: :albums

      String :filename, null: false
      String :image_data_secure
      String :description_secure

      #text type: https://github.com/jeremyevans/sequel/blob/master/doc/schema_modification.rdoc
      String :image_data, text: true 
      String :filetype

      DateTime :created_at
      DateTime :updated_at

      unique [:album_id]
    end
  end
end
