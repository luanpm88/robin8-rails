class RemoveInterestedAllFieldForKol < ActiveRecord::Migration
  def change
    remove_column :kols, :monetize_interested_all
  end
end
