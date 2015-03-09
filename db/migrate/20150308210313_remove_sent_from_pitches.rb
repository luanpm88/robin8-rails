class RemoveSentFromPitches < ActiveRecord::Migration
  def change
    remove_column :pitches, :sent, :boolean, default: false
  end
end
