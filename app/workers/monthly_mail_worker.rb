require 'mailgun'
class MonthlyMailWorker
  include Sidekiq::Worker

  def perform(post_id) 
    mg_client = Mailgun::Client.new Rails.application.secrets.mailgun[:api_key]
    domain = Rails.application.secrets.mailgun[:domain]
    campains_response = mg_client.get("#{domain}/campaigns")
    campaigns = JSON.parse(campains_response.body)['items']

    news_rooms = NewsRoom.joins(:releases)
      .select('news_rooms.*, releases.id as release_id, releases.title as release_title')
      .where(releases: { created_at: DateTime.now.beginning_of_month..DateTime.now.end_of_month })

    releases = {}

    news_rooms.each do |nr|
      releases[nr.id] = [] unless releases.has_key? nr.id
      releases[nr.id].push(nr)
    end

    view = ActionView::Base.new(Rails.root.join('app/views'))
    view.class.include ApplicationHelper
    html = view.render(partial: 'user_mailer/subscription', locals: { releases: Release.all} )

    releases.each do |key, rs|
      html = view.render(partial: 'user_mailer/subscription', locals: { releases: Release.all} )
      nr = NewsRoom.find key
      message_params = { from: 'bob@sending_domain.com', to: 'pavlo.shabat@perfectial.com', subject: 'Some subject', html: html, 'o:campaign' => nr.campaign_name }
    end
    
  end
end