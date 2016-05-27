module API
  module V2
    module Entities
      module RewardTaskEntities
        class Summary  < Grape::Entity
          expose :task_type, :task_name, :reward_amount
          expose :participate_status do |task, options|
            if task.task_type == RewardTask::CheckIn
              options[:kol].today_had_check_in? ? 'finished' : 'processing'
            elsif task.task_type == RewardTask::CompleteInfo
              options[:kol].had_complete_info? ? 'finished' : 'processing'
            else
              # RewardTask::FavorableComment
              'processing'
            end
          end
        end
      end
    end
  end
end