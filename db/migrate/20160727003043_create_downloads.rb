class CreateDownloads < ActiveRecord::Migration
  def change
    create_table :downloads do |t|
    	t.integer :owner_id
      t.string :owner_type
      
      t.belongs_to :folder#, index: true, foreign_key: true
      t.belongs_to :archive#, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
