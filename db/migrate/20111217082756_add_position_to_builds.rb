class AddPositionToBuilds < ActiveRecord::Migration
  def change
    add_column :builds, :position, :integer
  end
end
