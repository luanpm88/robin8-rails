class AddChNameToCrmSeller < ActiveRecord::Migration
  def change
    add_column :crm_sellers, :ch_name, :string
  end
end
