class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
    	t.text :title
      t.text :message
      t.string :notification_type
      t.text :action
      
      t.belongs_to :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
