class IptcCategory < ActiveRecord::Base
  default_scope -> {where(:scene => 'US')}

  scope :us, -> {where(:scene => 'US')}
  scope :cn, ->   {where(:scene => 'CN')}

  def self.starts_with(str)
    where("lower(label) like ?", "#{str.downcase}%")
  end

  def capitalized_label
    label.split.map { |i| i.capitalize }.join(' ')
  end
end
