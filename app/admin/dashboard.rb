ActiveAdmin.register_page "Dashboard" do

  # menu priority: 1, label: proc{ I18n.t("active_admin.dashboard") }
  menu priority: 1, label: 'Dashboard'

  # content title: proc{ I18n.t("active_admin.dashboard") } do
  content title: 'Dashboard' do
    div class: "blank_slate_container", id: "dashboard_default_message" do
      span class: "blank_slate" do
        span ("Welcome to Robin8 Admin Panel")
        # small ("active_admin.dashboard_welcome.call_to_action")
      end
    end

     columns do
       column do
         panel "Recent Streams" do
           ul do
             Stream.order("created_at DESC").limit(5).map do |stream|
               li link_to(stream.name, admin_stream_path(stream))
             end
           end
         end
       end

       column do
         panel "Recent Releases" do
           ul do
             Release.order("created_at DESC").limit(5).map do |release|
               li link_to(release.title, admin_release_path(release))
             end
           end
         end
       end

       column do
         panel "Recent Users" do
           ul do
             User.order("created_at DESC").limit(5).map do |user|
               li link_to(user.name, admin_user_path(user))
             end
           end
         end
       end

     end
  end # content
end
