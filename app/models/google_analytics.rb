class GoogleAnalytics
  extend Legato::Model

  extend Legato::Model
  metrics :sessions, :page_views, :organicSearches
  dimensions :date
  
  filter :for_hostname, &lambda {|hostname| matches(:hostname, hostname)}

end