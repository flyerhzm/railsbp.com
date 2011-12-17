class AddFinishedAtToBuilds < ActiveRecord::Migration
  def change
    add_column :builds, :finished_at, :datetime
  end
end
