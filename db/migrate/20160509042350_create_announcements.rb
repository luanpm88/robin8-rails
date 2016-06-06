class CreateAnnouncements < ActiveRecord::Migration
  def change
    create_table :announcements do |t|
      t.string :title
      t.string :logo
      t.string :banner
      t.string :desc
      t.boolean :display, :default => false
      t.integer :position, :default => 0
      t.string :detail_type
      t.string :url

      t.timestamps null: false
    end

     Announcement.create(:title => '邀请好友', :detail_type => 'invite_friend')
     Announcement.create(:title => '每日签到', :detail_type => 'check_in')
     Announcement.create(:title => '完善资料', :detail_type => 'complete_info')
     Announcement.create(:title => '夺宝', :detail_type => 'indiana')
  end
end
