class AgentKol < ActiveRecord::Base
  belongs_to :kol
  belongs_to :agent, class_name: "Kol"
end
