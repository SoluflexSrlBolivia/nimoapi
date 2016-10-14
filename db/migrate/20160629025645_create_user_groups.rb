class CreateUserGroups < ActiveRecord::Migration
  def change
    create_table :user_groups do |t|
    	t.boolean  :notification, default: true
    	t.integer  :rate, default: 0
      t.string   :alias
    	
      t.belongs_to :user
      t.belongs_to :group
      
      t.timestamps null: false
    end
  end
end
