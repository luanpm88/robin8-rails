class AddIsContinuousToTaskRecords < ActiveRecord::Migration
  def change
    add_column :task_records, :is_continuous, :integer, :default => 0
  end
end
