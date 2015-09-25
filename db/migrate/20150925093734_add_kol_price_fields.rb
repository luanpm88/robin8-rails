class AddKolPriceFields < ActiveRecord::Migration
  def change
    add_column :kols, :monetize_intrested_all, :boolean
    add_column :kols, :monetize_intrested_post, :boolean
    add_column :kols, :monetize_intrested_create, :boolean
    add_column :kols, :monetize_intrested_share, :boolean
    add_column :kols, :monetize_intrested_review, :boolean
    add_column :kols, :monetize_intrested_speech, :boolean
    add_column :kols, :monetize_intrested_event, :boolean
    add_column :kols, :monetize_intrested_focus, :boolean
    add_column :kols, :monetize_intrested_party, :boolean
    add_column :kols, :monetize_intrested_endorsements, :boolean

    add_column :kols, :monetize_post, :integer
    add_column :kols, :monetize_post_weibo, :integer
    add_column :kols, :monetize_post_personal, :integer
    add_column :kols, :monetize_post_public1st, :integer
    add_column :kols, :monetize_post_public2nd, :integer

    add_column :kols, :monetize_create, :integer
    add_column :kols, :monetize_create_weibo, :integer
    add_column :kols, :monetize_create_personal, :integer
    add_column :kols, :monetize_create_public1st, :integer
    add_column :kols, :monetize_create_public2nd, :integer

    add_column :kols, :monetize_share, :integer
    add_column :kols, :monetize_share_weibo, :integer
    add_column :kols, :monetize_share_personal, :integer
    add_column :kols, :monetize_share_public1st, :integer
    add_column :kols, :monetize_share_public2nd, :integer

    add_column :kols, :monetize_review, :integer
    add_column :kols, :monetize_review_weibo, :integer
    add_column :kols, :monetize_review_personal, :integer
    add_column :kols, :monetize_review_public1st, :integer
    add_column :kols, :monetize_review_public2nd, :integer

    add_column :kols, :monetize_speech, :integer
    add_column :kols, :monetize_speech_weibo, :integer
    add_column :kols, :monetize_speech_personal, :integer
    add_column :kols, :monetize_speech_public1st, :integer
    add_column :kols, :monetize_speech_public2nd, :integer

    add_column :kols, :monetize_event, :integer
    add_column :kols, :monetize_focus, :integer
    add_column :kols, :monetize_party, :integer
    add_column :kols, :monetize_endorsements, :integer

  end
end
