class Localization
  attr_reader :store
  attr_accessor :locale

  def initialize
    @store ||= Redis.new(db: 10)
    @locale ||= 'en'
  end

  def t keys, application = true
    keys = application ? ['application'] + keys.split('.') : keys.split('.')
    r = storage
    begin
      keys.each { |key| r = r.send '[]', key }
    rescue Exception => e
      r = "#{keys.join('.')}: missing translation"
    end
    r
  end

  def locale= locale
    @locale = locale
    @storage = nil
  end

  def storage
    @storage ||= JSON.parse(store.get(locale))
  end

end