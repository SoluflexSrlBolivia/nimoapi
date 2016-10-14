class CreateRateArchives < ActiveRecord::Migration
  def change
    create_table :rate_archives do |t|
      t.integer :rate
      t.belongs_to :user
      t.belongs_to :archive

      t.timestamps null: false
    end
  end
end
