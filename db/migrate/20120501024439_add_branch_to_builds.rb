class AddBranchToBuilds < ActiveRecord::Migration
  def change
    add_column :builds, :branch, :string, default: "master", null: false

  end
end
