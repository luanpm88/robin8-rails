class AddKolPriceFieldsFix < ActiveRecord::Migration
  def change
    remove_column :kols, :monetize_intrested_all
    remove_column :kols, :monetize_intrested_post
    remove_column :kols, :monetize_intrested_create
    remove_column :kols, :monetize_intrested_share
    remove_column :kols, :monetize_intrested_review
    remove_column :kols, :monetize_intrested_speech
    remove_column :kols, :monetize_intrested_event
    remove_column :kols, :monetize_intrested_focus
    remove_column :kols, :monetize_intrested_party
    remove_column :kols, :monetize_intrested_endorsements


    add_column :kols, :monetize_interested_all, :boolean
    add_column :kols, :monetize_interested_post, :boolean
    add_column :kols, :monetize_interested_create, :boolean
    add_column :kols, :monetize_interested_share, :boolean
    add_column :kols, :monetize_interested_review, :boolean
    add_column :kols, :monetize_interested_speech, :boolean
    add_column :kols, :monetize_interested_event, :boolean
    add_column :kols, :monetize_interested_focus, :boolean
    add_column :kols, :monetize_interested_party, :boolean
    add_column :kols, :monetize_interested_endorsements, :boolean
  end
end
