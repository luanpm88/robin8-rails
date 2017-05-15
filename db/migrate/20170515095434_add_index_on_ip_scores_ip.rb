class AddIndexOnIpScoresIp < ActiveRecord::Migration
  def change
    change_column :ip_scores, :ip, :string, limit: 25
    add_index :ip_scores, :ip
  end
end
