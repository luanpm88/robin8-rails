class AddTokenToPushRecord < ActiveRecord::Migration
  def change
  	add_column :campaign_push_records , :device_tokens, :string
  end
end
