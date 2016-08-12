class CreateAgentKols < ActiveRecord::Migration
  def change
    create_table :agent_kols do |t|
      t.references :agent
      t.references :kol
      t.timestamps null: false
    end
    add_index :agent_kols, :kol_id
    add_index :agent_kols, :agent_id
  end
end
