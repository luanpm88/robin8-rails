ActiveAdmin.register Feedback do

  remove_filter :kol
  controller do
    def scoped_collection
      Feedback.includes(:kol)   # includes User / Brand models in listing products
    end
  end

  index do
    column "Kol" do |resource|
      (link_to resource.kol.id, "/admin/kols/#{resource.kol.id}", :target => "_blank")
    end

    column "mobile_number" do |resource|
      resource.kol.mobile_number
    end

    column :app_version
    column :app_platform
    column :os_version
    column :device_model
    column :content
    column :screeshot do |resource|
      image_tag resource.screeshot.url
    end
    column :created_at
  end
end
