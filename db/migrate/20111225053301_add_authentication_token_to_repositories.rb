class AddAuthenticationTokenToRepositories < ActiveRecord::Migration
  def change
    add_column :repositories, :authentication_token, :string
  end
end
