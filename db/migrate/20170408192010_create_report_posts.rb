class CreateReportPosts < ActiveRecord::Migration
  def change
    create_table :report_posts do |t|
      t.belongs_to :post
      t.belongs_to :group

      t.integer :informer_id

      t.timestamps null: false
    end
  end
end
