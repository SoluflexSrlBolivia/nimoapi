class CreateRatePosts < ActiveRecord::Migration
  def change
    create_table :rate_posts do |t|
      t.integer :rate
      t.belongs_to :user
      t.belongs_to :post

      t.timestamps null: false
    end
  end
end
