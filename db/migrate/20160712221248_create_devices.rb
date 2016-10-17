class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
      t.string :identifier
      t.string :player_id
      t.string :name_device
      t.string :version
      t.string :os
      t.string :model
      
      t.belongs_to :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
