class CreatePrivateKols < ActiveRecord::Migration
  def change
    create_table :private_kols do |t|
      t.belongs_to :kol, index: true
      t.belongs_to :user, index: true
    end
  end
end
