class CreateArchives < ActiveRecord::Migration
  def change
    create_table :archives do |t|
      t.text :description
      t.string :original_file_name
      t.integer :owner_id
      t.string :owner_type
      t.integer :uploader_id
      t.string :alias

      t.references :archivable, polymorphic: true, index: true

      t.timestamps null: false
    end
  end
end
