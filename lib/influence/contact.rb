module Influence
  class Contact
    def self.cal_score(kol_uuid)
      total_score = get_contact_level_score(kol_uuid)
      total_score
    end

    #计算 加权好友数后 得分
    ContactLevels = [{:min_count => 500, :score => 100},
                     {:min_count => 400, :score => 90},
                     {:min_count => 300, :score => 80},
                     {:min_count => 200, :score => 70},
                     {:min_count => 100, :score => 60},
                     {:min_count => 80, :score => 50},
                     {:min_count => 60, :score => 40},
                     {:min_count => 50, :score => 30},
                     {:min_count => 30, :score => 20},
                     {:min_count => 20, :score => 10},
                     {:min_count => -1, :score => 0}]
    def self.get_contact_level_score(kol_uuid, contact_count = nil)
      contact_count = TmpKolContact.where(:kol_uuid => kol_uuid).count
      ContactLevels.each do |level|
        return level[:score]  if contact_count > level[:min_count]
      end
    end
  end
end
