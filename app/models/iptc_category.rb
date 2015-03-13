class IptcCategory < ActiveRecord::Base

  def capitalized_label
    label.split.map { |i| i.capitalize }.join(' ')
  end
end
