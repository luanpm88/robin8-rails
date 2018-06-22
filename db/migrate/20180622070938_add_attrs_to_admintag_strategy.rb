class AddAttrsToAdmintagStrategy < ActiveRecord::Migration
  def change
  	add_column :admintag_strategies, :invites_max_count, :integer, default: 10
  end
end
