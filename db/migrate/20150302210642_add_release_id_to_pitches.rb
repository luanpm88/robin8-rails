class AddReleaseIdToPitches < ActiveRecord::Migration
  def change
    add_column :pitches, :release_id, :integer
    change_column :pitches, :summary_length, :integer, limit: 1
  end
end
