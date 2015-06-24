class DeleteBankAccountFildFromKols < ActiveRecord::Migration
  def change
  	remove_column :kols, :bank_account, :string
  end
end
