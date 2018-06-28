class TaskRecord < ActiveRecord::Base
  belongs_to :kol
  belongs_to :reward_task, :foreign_key => 'task_type', :primary_key => 'task_type'
  belongs_to :invitees, :foreign_key => 'invitees_id', :primary_key => 'kol_id', :class_name => Kol

  validates_inclusion_of :status, in: %w(active pending)

  scope :active, -> {where(:status => 'active')}
  scope :complete_info,  -> {where(:task_type => RewardTask::CompleteInfo)}
  scope :favorable_comment,  ->{where(:task_type => RewardTask::FavorableComment)}
  scope :check_in,   -> {where(:task_type => RewardTask::CheckIn)}
  scope :invite_friend,   -> {where(:task_type => RewardTask::InviteFriend)}
  scope :today, -> {where(:created_at => Time.now.beginning_of_day..Time.now.end_of_day)}
  scope :created_desc, -> {order("created_at desc")}

  #旧的
  def sync_to_transaction
    return if self.status != 'active'
    reward_task = RewardTask.find_by :task_type => self.task_type
    return if reward_task.blank?
    Rails.logger.transaction.info self.inspect
    case task_type
    when 'invite_friend'
      self.kol.income(kol.strategy[:invite_bounty], self.task_type, self )
    end
  end

  #新的
  def new_sync_to_transaction
    return if self.status != 'active'
    reward_task = RewardTask.find_by :task_type => self.task_type
    return if reward_task.blank?
    Rails.logger.transaction.info self.inspect
    if self.task_type == "check_in"
      case self.kol.update_check_in
      when 1
        self.kol.income(0.1, self.task_type, self )
      when 2
        self.update(:is_continuous => 1)
        self.kol.task_records.where(:created_at => Date.yesterday.beginning_of_day..Date.yesterday.end_of_day).update_all(:is_continuous => 1)
        self.kol.income(0.2, self.task_type, self )
      when 3
        self.update(:is_continuous => 1)
        self.kol.income(0.25, self.task_type, self )
      when 4
        self.update(:is_continuous => 1)
        self.kol.income(0.3, self.task_type, self )
      when 5
        self.update(:is_continuous => 1)
        self.kol.income(0.35, self.task_type, self )
      when 6
        self.update(:is_continuous => 1)
        self.kol.income(0.4, self.task_type, self )
      else
        self.update(:is_continuous => 1)
        self.kol.income(0.5, self.task_type, self )
      end
    else
      self.kol.income(reward_task.reward_amount, self.task_type, self )
    end
  end

end
