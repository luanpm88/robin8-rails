class CreateRewardTasks < ActiveRecord::Migration
  def change
    create_table :reward_tasks do |t|
      t.float :reward_amount
      t.string :reward_cycle
      t.integer :position
      t.string :task_name
      t.string :task_type, :limit => 191
      t.integer :limit        #预留
      t.string :logo         #预留
      t.boolean :enable, :default => true

      t.timestamps null: false
    end
    add_index :reward_tasks, :task_type
    RewardTask.create(:task_name => '每日签到', :reward_amount => 0.2, :task_type => RewardTask::CheckIn, :reward_cycle => 'every_day', :position => 1)
    RewardTask.create(:task_name => '完善资料', :reward_amount => 2, :task_type => RewardTask::CompleteInfo, :reward_cycle => 'first_time', :position => 2)
    RewardTask.create(:task_name => '邀请好友', :reward_amount => 2, :task_type => RewardTask::InviteFriend, :reward_cycle => 'every_time', :position => 3)
    RewardTask.create(:task_name => '好评App', :reward_amount => 2, :task_type => RewardTask::FavorableComment, :reward_cycle => 'first_time', :position => 4)
  end


end
