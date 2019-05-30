class ChangeSocialAccountsHomepageColumn < ActiveRecord::Migration
  def change
    change_column :social_accounts, :homepage, :text
  end
end
