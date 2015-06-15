class AddMyprgenieAndAccesswireAndPrnewswireToRelease < ActiveRecord::Migration
  def change
    add_column :releases, :myprgenie, :boolean
    add_column :releases, :accesswire, :boolean
    add_column :releases, :prnewswire, :boolean
  end
end
