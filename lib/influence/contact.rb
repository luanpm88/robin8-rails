module Influence
  class Contact
    def self.cal_score(kol_uuid, kol_id)
      if kol_id
        contact_count = KolContact.where(:kol_id => kol_id).count
      else
        contact_count = TmpKolContact.where(:kol_uuid => kol_uuid).count
      end
      score = (33 * Math.log10(contact_count)).round(0)
      score = 100 if score > 100
      score
    end

  end
end
