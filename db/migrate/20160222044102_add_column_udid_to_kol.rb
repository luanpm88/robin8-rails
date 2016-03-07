class AddColumnUdidToKol < ActiveRecord::Migration
  def change
    add_column :kols, :IMEI, :string
    add_column :kols, :IDFA, :string
  end
end
