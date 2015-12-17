class AddSocialNameColumnToKols < ActiveRecord::Migration
  def change
    add_column :kols, :social_name, :string
  end
end
