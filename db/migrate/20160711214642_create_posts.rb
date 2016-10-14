class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.text :post
      t.text :description
      t.string  :alias

      t.belongs_to :user
      t.belongs_to :group

      t.timestamps null: false
    end
  end
end
