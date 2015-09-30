class IptcCategory < ActiveRecord::Base

  def self.starts_with(str)
    where("lower(label) like ?", "#{str.downcase}%")
  end

  def capitalized_label
    label.split.map { |i| i.capitalize }.join(' ')
  end
end
