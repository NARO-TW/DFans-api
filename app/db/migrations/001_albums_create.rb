# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:albums) do
      primary_key :id

      String :name, unique: true, null: false
      String :description
      #String [:tags]

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
