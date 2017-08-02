class CreateAdmintags < ActiveRecord::Migration
  def change
    create_table :admintags do |t|
      t.string :tag

      t.timestamps null: false
    end
  end
end
