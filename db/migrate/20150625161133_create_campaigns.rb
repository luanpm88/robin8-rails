class CreateCampaigns < ActiveRecord::Migration
  def change
    create_table :campaigns do |t|
      t.string :name
      t.text :description
      t.datetime :deadline
      t.decimal :budget
      t.datetime :created_at
      t.belongs_to :user, index: true

      t.timestamps null: false
    end
  end
end
