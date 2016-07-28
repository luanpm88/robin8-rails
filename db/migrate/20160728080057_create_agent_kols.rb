class CreateAgentKols < ActiveRecord::Migration
  def change
    create_table :agent_kols do |t|
      t.references :agent
      t.references :kol
      t.timestamps null: false
    end
  end
end
