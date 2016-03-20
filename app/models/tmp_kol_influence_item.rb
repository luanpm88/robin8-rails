class TmpKolInfluenceItem < ActiveRecord::Base
  def self.store_item(kol_uuid, item_name, item_value, item_score, detail_content = nil)
    tmp_influence_item = TmpKolInfluenceItem.find_or_initialize_by(:kol_uuid => kol_uuid, :item_name => item_name)
    tmp_influence_item.item_value = item_value
    tmp_influence_item.item_score = item_score
    tmp_influence_item.detail_content = detail_content
    tmp_influence_item.save
  end
end
