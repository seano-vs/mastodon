# frozen_string_literal: true

class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.references :status, null: false, foreign_key: { on_delete: :cascade }, index: { unique: true }
      t.string :name, null: false
      t.datetime :starts_at, null: false
      t.string :time_zone
      t.string :location

      t.timestamps
    end
  end
end
