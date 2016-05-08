module API
  module V2
    module Entities
      module RewardTaskEntities
        class Summary  < Grape::Entity
          expose :task_type, :task_name, :reward_amount
          expose :participate_status do |task, options|
            if task.task_type == RewardTask::FavorableComment
              options[:kol]
            else
            end
          end
        end
      end
    end
  end
end
