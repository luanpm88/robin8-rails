module API
  module V2
    module Entities
      module RewardTaskEntities
        class Summary  < Grape::Entity
          expose :task_type, :task_name, :reward_amount
          expose :participate_status do |task, options|
            if task.task_type == RewardTask::CheckIn
              options[:kol].today_had_check_in? ? 'active' : 'pending'
            elsif task.task_type == RewardTask::CompleteInfo
              options[:kol].had_complete_info? ? 'active' : 'pending'
            else
              # RewardTask::FavorableComment
              'pending'
            end
          end
        end
      end
    end
  end
end
