class AddSerialParamsToIdentities < ActiveRecord::Migration
  def change
    add_column :identities, :serial_params, :text
    add_column :identities, :service_type_info, :string
    add_column :identities, :verify_type_info, :string
    add_column :identities, :wx_user_name, :string
  end
end
