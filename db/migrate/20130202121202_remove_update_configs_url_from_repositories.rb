class RemoveUpdateConfigsUrlFromRepositories < ActiveRecord::Migration
  def up
    remove_column :repositories, :update_configs_url
  end

  def down
    add_column :repositories, :update_configs_url, :string
  end
end
