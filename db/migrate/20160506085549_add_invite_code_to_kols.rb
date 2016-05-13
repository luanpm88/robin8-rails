class AddInviteCodeToKols < ActiveRecord::Migration
  def change
    add_column :kols, :alipay_name, :string
    add_column :kols, :invite_code, :string, :limit => 10

    add_index :kols, :invite_code

    # Kol.find_each do |kol|
    #   kol.generate_invite_code
    # end
  end
end
