class AddSerialParamsToIdentities < ActiveRecord::Migration
  def change
    add_column :identities, :serial_params, :text
  end
end
