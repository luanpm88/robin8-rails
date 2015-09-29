require 'time'
namespace :mailgun do
  desc 'Save Mailgun events into DB, launch without params for full event downloading'
  task :shoot, [:arg] => :environment do |t, args|
    mg_client = Mailgun::Client.new Rails.application.secrets.mailgun[:api_key]
    domain = Rails.application.secrets.mailgun[:domain]

    puts 'Downloading Mailgun events...'

    url_params = {limit: 300}
    if !args['arg'].nil?
      url_params[:begin] = (Time.now - 70.minutes).rfc2822
      url_params[:end] = Time.now.rfc2822
    end

    res_list = []
    items, next_page = fetch_items(mg_client, "#{domain}/events", url_params)
    until items.length == 0
      res_list.concat(items)
      puts 'Downloaded %s events.' % res_list.length
      items, next_page = fetch_items(mg_client, "#{domain}/events/" + next_page, url_params)
    end

    print 'Processing data'

    res_list.each do |event|
      data = {
        event_type: event['event'],
        event_time: DateTime.strptime(event['timestamp'].to_s.split('.')[0], '%s'),
        severity: event['severity'],
        recipient: event['recipient']
      }

      if !event['geolocation'].nil?
        data['country'] = event['geolocation']['country']
      end
      if !event['delivery-status'].nil?
        data['delivery_status'] = event['delivery-status']['message']
      end
      if !event['envelope'].nil?
        data['sender'] = event['envelope']['sender']
      end

      if event['campaigns'].blank?
        MailgunEvent.find_or_create_by(data)
      else
        event['campaigns'].each do |campaign|
          data['campaign_name'] = campaign['name']
          MailgunEvent.find_or_create_by(data)
        end
      end
      print '.'
    end
    puts
    puts 'All events were processed.'
  end

  def fetch_items(mg_client, url, params)
    result = mg_client.get(url, params)
    r = JSON.parse(result.body)
    next_page = r['paging']['next'].split('/').last
    items = r['items']
    return items, next_page
  end
end
