class AddChannelToKol < ActiveRecord::Migration
  def change
  	add_column :kols , :channel ,:string
  	add_column :kols , :cid ,:integer
  end
end
