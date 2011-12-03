class AddSshUrlToRepositories < ActiveRecord::Migration
  def change
    add_column :repositories, :ssh_url, :string
  end
end
