# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:albums) do
      primary_key :id
      foreign_key :owner_id, :accounts
      String :name, null: false
      String :description_secure
      # String :tags

      DateTime :created_at
      DateTime :updated_at

      unique [:id]
    end
  end
end
