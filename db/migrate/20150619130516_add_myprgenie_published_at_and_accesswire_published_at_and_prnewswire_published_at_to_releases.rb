class AddMyprgeniePublishedAtAndAccesswirePublishedAtAndPrnewswirePublishedAtToReleases < ActiveRecord::Migration
  def change
    add_column :releases, :myprgenie_published_at, :date
    add_column :releases, :accesswire_published_at, :date
    add_column :releases, :prnewswire_published_at, :date
  end
end
