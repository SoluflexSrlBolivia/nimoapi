class AddDimensionToArchives < ActiveRecord::Migration
  def change
    add_column :archives, :image_width, :integer
    add_column :archives, :image_height, :integer
  end
end
