class AddChannelToCampaign < ActiveRecord::Migration
  def change
  	add_column :campaigns , :channel ,:string
  end
end
