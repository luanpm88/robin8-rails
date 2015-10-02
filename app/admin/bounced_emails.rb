ActiveAdmin.register_page "Bounced emails" do

  limit = 100

  content do
    url = URI.parse("#{Rails.application.secrets[:mailgun][:api_base_url]}/bounces?limit=#{limit}")
    unless params["q"].nil?
      url = URI.parse("#{Rails.application.secrets[:mailgun][:api_base_url]}/bounces/#{params["q"]["email_equals"]}") unless params["q"]["email_equals"].nil?
    end
    unless params["page"].nil?
      url = URI.parse("#{Rails.application.secrets[:mailgun][:api_base_url]}/bounces?page=#{params["page"]}&address=#{params["address"]}&limit=#{limit}")
    end

    response = {}
    res = Net::HTTP.start(url.hostname,url.port, :use_ssl => url.scheme == 'https') do |http|
      req = Net::HTTP::Get.new url
      req.basic_auth "#{Rails.application.secrets[:mailgun][:api_key]}","#{Rails.application.secrets[:mailgun][:api_key]}"
      resp = http.request req
    end

    if res.is_a?(Net::HTTPSuccess)
      response = JSON.parse(res.body)
    end

    emails = response["items"] || response

    if emails.length > 0

      if params["page"].nil? && params["q"].nil?
        session[:first_item] = emails[0]["address"]
      end

      div :class => 'bounced_emails_content' do
        table_for emails, { :class => 'index_table bounced_table'} do
          column ('Email address') { |i| i["address"] }
          column ("Error code") { |i| i["code"] }
          column ("Error message") { |i| i["error"] }
          column ("Send at") { |i| i["created_at"] }
        end

        panel "Search details", {:class => 'panel filter_emails'} do
          render :partial => "form"
        end
      end

      if !response["paging"].nil?
        previous_page = response["paging"]["previous"].split('?')[1]
        next_page = response["paging"]["next"].split('?')[1]

        div :class => 'admin_bounced_btns' do
          if previous_page!="limit=#{limit}" && !params["page"].nil? && (session[:first_item] != emails[0]["address"])
            link_to 'Prev', 'bounced_emails?' <<  previous_page
          else 'Prev'
          end
        end
        div :class => 'admin_bounced_btns' do
          if next_page!="limit=#{limit}" && emails.length == limit
            link_to 'Next', 'bounced_emails?' << next_page
          else 'Next'
          end
        end
      end
    else
      h2 do
        "No results."
      end
      if !params["page"].nil?
        button do
          link_to 'Back', :back
        end
      end
    end
  end

  page_action :email_filter, method: :get do
    redirect_to :back
  end

end
