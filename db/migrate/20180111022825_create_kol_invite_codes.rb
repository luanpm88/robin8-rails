class CreateKolInviteCodes < ActiveRecord::Migration
  def change
    create_table :kol_invite_codes do |t|
      t.integer    :code
      t.integer    :kol_id
      t.timestamps null: false
    end
  end
end
