class Localization
  attr_reader :store
  def initialize
    @store ||= Redis.new(db: 10)
  end
end