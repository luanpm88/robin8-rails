class CreateIpScores < ActiveRecord::Migration
  def change
    create_table :ip_scores do |t|
      t.string :ip
      t.integer :score

      t.timestamps null: false
    end
  end
end
