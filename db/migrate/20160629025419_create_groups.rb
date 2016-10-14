class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string 	:name
      t.text 		:description
      t.string 	:keyword    #is just for Private
      t.integer :privacity, default: 1 #1=Abierto, 2=Cerrado, 3=Privado(keyword)
      t.integer :admin_id #user id who created
      t.boolean  :deleted, default: false

      t.timestamps null: false
    end
  end
end
