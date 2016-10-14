class CreateAliases < ActiveRecord::Migration
  def change
    create_table :aliases do |t|
      t.string :name
      
      t.references :aliasable, polymorphic: true, index: true

      t.timestamps null: false
    end
  end
end
