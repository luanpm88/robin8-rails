class AddStatusToCompetitors < ActiveRecord::Migration
  def change
    add_column :competitors, :status, :integer, default: 1
  end
end
