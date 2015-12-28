class AddFromWhichCampaignColumnToKol < ActiveRecord::Migration
  def change
    add_column :kols, :from_which_campaign, :string
  end
end
