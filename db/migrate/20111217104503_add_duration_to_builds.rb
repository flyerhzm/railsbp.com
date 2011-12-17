class AddDurationToBuilds < ActiveRecord::Migration
  def change
    add_column :builds, :duration, :integer, :default => 0
  end
end
