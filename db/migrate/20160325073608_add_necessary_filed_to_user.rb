class AddNecessaryFiledToUser < ActiveRecord::Migration
  def change
    add_column :users, :url, :string
    add_column :users, :description, :string
    add_column :users, :keywords, :string
    add_column :users, :real_name, :string
  end
end
