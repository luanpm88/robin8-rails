class TaskRecord < Record::Base
  belongs_to :kol
  belongs_to :reward_task, :foreign_key => 'task_type', :primary_key => 'task_type'
  belongs_to :invitees, :foreign_key => 'invitees_id', :primary_key => 'kol_id', :class_name => Kol

  validates_inclusion_of :status, in: %w(active pending)



  scope :active, -> {where(:status => 'active')}
  scope :complete_info,  -> {where(:task_type => RewardTask::InviteFriend)}
  scope :favorable_comment,  ->{where(:task_type => RewardTask::FavorableComment)}
  scope :check_in,   -> {where(:task_type => RewardTask::CheckIn)}
  scope :today, -> {where(:created_at => Time.now.beginning_of_day..Time.now.end_of_day)}

  # after_save :sync_to_transaction

  def sync_to_transaction
    return if self.status != 'active'
    reward_task = RewardTask.find_by :task_type => self.task_type
    return if reward_task.blank?
    Rails.logger.transaction.info self.inspect
    self.kol.transaction.income(reward_task.reward_amount, self.task_type, self )
  end

end
