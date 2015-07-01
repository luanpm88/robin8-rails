class AddMyprgenieAndAccesswireAndPrnewswireToRelease < ActiveRecord::Migration
  def change
    add_column :releases, :myprgenie, :boolean, :default => false
    add_column :releases, :accesswire, :boolean, :default => false
    add_column :releases, :prnewswire, :boolean, :default => false
  end
end
