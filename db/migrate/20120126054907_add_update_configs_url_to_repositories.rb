class AddUpdateConfigsUrlToRepositories < ActiveRecord::Migration
  def change
    add_column :repositories, :update_configs_url, :string
  end
end
