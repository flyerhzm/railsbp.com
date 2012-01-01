class RemoveTimestampFromCatogires < ActiveRecord::Migration
  def up
    remove_column :categories, :created_at
    remove_column :categories, :updated_at
  end

  def down
    add_column :categories, :updated_at, :datetime
    add_column :categories, :created_at, :datetime
  end
end
