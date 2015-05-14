# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "http://www.example.com"#Rails.application.secrets[:host]

SitemapGenerator::Sitemap.create do
  # Put links creation logic here.
  #
  # The root path '/' and sitemap index file are added automatically for you.
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: add(path, options={})
  #        (default options are used if you don't specify)
  #
  # Defaults: :priority => 0.5, :changefreq => 'weekly',
  #           :lastmod => Time.now, :host => default_host
  #
  # Examples:
  #
  # Add '/articles'
  #
  add root_path, :priority => 0.7, :changefreq => 'daily'
  add about_path, :priority => 0.7, :changefreq => 'daily'
  add team_path, :priority => 0.7, :changefreq => 'daily'
  add terms_path, :priority => 0.7, :changefreq => 'daily'
  add pricing_path, :priority => 0.7, :changefreq => 'daily'
  add signin_path, :priority => 0.7, :changefreq => 'daily' 
  add signup_path, :priority => 0.7, :changefreq => 'daily'
  add '/contact', :priority => 0.7, :changefreq => 'daily'
  #
  # Add all articles:
  #
  NewsRoom.find_each do |news_room|
    add news_room.permalink, :lastmod => news_room.updated_at
    
    news_room.releases.each do |release|
      add release.permalink, :lastmod => release.updated_at
    end
  end
end
