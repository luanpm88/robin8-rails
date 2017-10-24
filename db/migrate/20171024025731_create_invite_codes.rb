class CreateInviteCodes < ActiveRecord::Migration
  def change
    create_table :invite_codes do |t|
      t.integer    :code
      t.string     :invite_type
      t.string     :invite_value
      t.timestamps null: false
    end
  end
end
