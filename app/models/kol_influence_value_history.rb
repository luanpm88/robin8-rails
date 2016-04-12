class KolInfluenceValueHistory < ActiveRecord::Base
  def self.generate_history(kol_value, is_auto)
    attrs  = kol_value.attributes
    attrs.delete("id")
    history = KolInfluenceValueHistory.new(:is_auto => is_auto)
    history.attributes = attrs
    history.save
  end

end
