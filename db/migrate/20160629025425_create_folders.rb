class CreateFolders < ActiveRecord::Migration
  def change
    create_table :folders do |t|
      t.string :name
      t.text :description
      t.integer :owner_id
      t.string :owner_type
      
      t.references :folderable, polymorphic: true, index: true

      t.timestamps null: false
    end
  end
end
