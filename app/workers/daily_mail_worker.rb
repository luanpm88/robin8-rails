class DailyMailWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  # recurrence { daily }

  def perform

    url = "https://api:#{Rails.application.secrets.mailgun[:api_key]}@api.mailgun.net/v2/rs0a72f7346d4e4278ab41c37b411d93ce.mailgun.org/"
    campaigns = JSON.parse(RestClient.get(url + 'campaigns'))['items']

    news_rooms = NewsRoom.joins(:releases)
      .select('news_rooms.*, releases.id as release_id, releases.title as release_title')
      .where(releases: { created_at: DateTime.now.beginning_of_day..DateTime.now.end_of_day })

    releases = {}

    news_rooms.each do |nr|
      releases[nr.id] = [] unless releases.has_key? nr.id
      releases[nr.id].push(nr)
    end

    mailgun = Mailgun()
    list = mailgun.list_members("daily@mg.robin8.com").list
    result = {}

    list.each do |l|
      result[l['vars']['newsroom_id']] = [] unless result.has_key? l['vars']['newsroom_id']
      result[l['vars']['newsroom_id']].push(l['address'])
      result[l['vars']['newsroom_id']].push(releases[l['vars']['newsroom_id']])
    end

  end
end