ActiveAdmin.register NewsRoom do

  permit_params :user_id, :company_name, :room_type, :size, :email, :phone_number,
                :fax, :web_address, :description, :address_1, :address_2, :city,
                :state, :postal_code, :country, :owner_name, :job_title, :facebook_link,
                :twitter_link, :linkedin_link, :instagram_link, :tags, :subdomain_name,
                :logo_url, :toll_free_number, :default_news_room, :publish_on_website, :campaign_name

  form do |f|
    VALID_TYPES = ['Government Agency', 'Non-Profit', 'Privately Held', 'Public Company', 'LLC', 'Educational Institution']
    VALID_SIZES = ['Myself Only', '1-5 employees', '6-10 employees', '11-50 employees', '51-200 employees', '201-500 employees',
                   '501-1000 employees', '1001-5000 employees', '5001-10,000 employees', '10,001 or more employees']
    f.inputs "NewsRoom" do
      f.input :user
      f.input :company_name
      f.input :room_type, :as => :select, :collection => VALID_TYPES
      f.input :size, :as => :select, :collection => VALID_SIZES
      f.input :email
      f.input :phone_number
      f.input :fax
      f.input :web_address
      f.input :description
      f.input :address_1
      f.input :address_2
      f.input :city
      f.input :state
      f.input :postal_code
      f.input :country
      f.input :owner_name
      f.input :job_title
      f.input :facebook_link
      f.input :twitter_link
      f.input :linkedin_link
      f.input :instagram_link
      f.input :tags
      f.input :subdomain_name
      f.input :logo_url
      f.input :toll_free_number
      f.input :default_news_room
      f.input :publish_on_website
      f.input :campaign_name
    end
    f.actions
  end

end
