class AddFileColumsToArchive < ActiveRecord::Migration
  def up
    add_attachment :archives, :digital
  end

  def down
    remove_attachment :archives, :digital
  end
end
