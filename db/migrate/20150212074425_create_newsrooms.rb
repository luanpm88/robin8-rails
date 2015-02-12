class CreateNewsrooms < ActiveRecord::Migration
  def change
    create_table :news_rooms do |t|
        t.integer :user_id
        t.string :company_name
        t.string :room_type
        t.string :size
        t.string :email
        t.string :phone_number
        t.string :fax
        t.string :web_address
        t.text   :description
        t.string :address_1
        t.string :address_2
        t.string :city
        t.string :state
        t.string :postal_code
        t.string :country
        t.string :owner_name
        t.string :job_title
        t.string :facebook_link
        t.string :twitter_link
        t.string :linkedin_link
        t.string :instagram_link
        t.timestamps null: false
    end
    add_index :news_rooms, :user_id
  end
end
