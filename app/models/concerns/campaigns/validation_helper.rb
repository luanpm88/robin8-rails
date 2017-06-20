module Campaigns
  module ValidationHelper
    extend ActiveSupport::Concern
    included do
      before_validation :validate_columns_if_changed
    end
    def validate_columns_if_changed
      if self.name_changed?
        if self.name.to_s.size > 60
          self.errors[:name] = "活动标题不能超过62个字!"
        end
      end

      if self.description_changed?
        if self.description.to_s.size > 500
          self.errors[:description] = "活动描述不能超过500个字!"
        end
      end
      if self.per_action_budget_changed?
        if self.per_action_budget > self.budget
          self.errors[:per_action_budget] = "单个奖励不能大于总预算!"
        end
      end
    end
  end
end
