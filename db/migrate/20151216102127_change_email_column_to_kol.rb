class ChangeEmailColumnToKol < ActiveRecord::Migration
  def change
    change_column_default :kols, :email, nil
    change_column_null :kols, :email, true
  end
end
