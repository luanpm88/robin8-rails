class AddColumnScreentshotToFeedbacks < ActiveRecord::Migration
  def change
    add_column :feedbacks, :screenshot, :string
  end
end
