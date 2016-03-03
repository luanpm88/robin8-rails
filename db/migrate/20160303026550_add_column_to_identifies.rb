class AddColumnToIdentifies < ActiveRecord::Migration
  def change
    add_column :identities, :followers_count, :integer
    add_column :identities, :friends_count, :integer
    add_column :identities, :statuses_count, :integer
    add_column :identities, :registered_at, :datetime
    add_column :identities, :verified, :boolean, :default => false

    add_column :identities, :refresh_token, :string
    add_column :identities, :refresh_time, :datetime

    Identity.where(:provider => 'weibo').where("created_at >= '#{7.days.ago}'").each do |identity|
      puts "get_value_info-----#{identity.id}"
      identity.get_value_info
    end
  end


end
