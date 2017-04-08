class CreateReportArchives < ActiveRecord::Migration
  def change
    create_table :report_archives do |t|
      t.belongs_to :archive, index: true, foreign_key: true
      t.belongs_to :group, index: true, foreign_key: true
      t.integer :informer_id

      t.timestamps null: false
    end
  end
end
