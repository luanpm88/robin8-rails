namespace :localization do
  desc "Generates Redis localization from yaml files"
  task upload: :environment do
    l = Localization.new
    translations = I18n.backend.send(:translations)
    l.store.set('en', translations[:en].to_json)
    l.store.set('zh', translations[:zh].to_json)
  end

  desc "Dumps Redis localizations into yaml files"
  task dump: :environment do
    out = ENV['dest'] || Rails.root.join('config', 'locales/').to_s
    source = Dir[Rails.root.join('config', 'locales', '*.yml').to_s]
    date = Time.now.strftime("%d%m%Y%H%M")
    dest = Rails.root.join('config', 'locales_backup', date).to_s
    FileUtils::mkdir_p dest
    source.each do |filename|
      FileUtils.cp(filename, dest)
    end
    saveYaml('en', out)
    saveYaml('zh', out)
  end

  def saveYaml(locale, out)
    l = Localization.new
    l.locale = locale
    phrases = l.store.get(locale)
    translate = JSON.parse(phrases)
    translate = {locale => translate}
    translate = sort(translate, true)
    File.open("#{out}#{locale}.yml", 'w') {|f| f.write YAML::dump(translate) }
  end

  def sort(object, deep = false)
    if object.is_a?(Hash)
      res = returning(Hash.new) do |map|
        object.each {|k, v| map[k] = deep ? sort(v, deep) : v }
      end
      return res.class[res.sort {|a, b| a[0].to_s <=> b[0].to_s } ]
    elsif deep && object.is_a?(Array)
      array = Array.new
      object.each_with_index {|v, i| array[i] = sort(v, deep) }
      return array
    else
      return object
    end
  end

  def returning(value)
    yield(value)
    value
  end
end
