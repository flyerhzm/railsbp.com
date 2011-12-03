class AddHtmlUrlToRepositories < ActiveRecord::Migration
  def change
    add_column :repositories, :html_url, :string
    remove_column :repositories, :url
  end
end
