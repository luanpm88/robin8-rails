namespace :localization do
  desc "Generates Redis localization from yaml files"
  task upload: :environment do
    l = Localization.new
    translations = I18n.backend.send(:translations)
    l.store.set('en', translations[:en].to_json)
    l.store.set('zh', translations[:zh].to_json)
  end
end