module Jd
  class OffShelf

    def self.go
      off_shelf_materials
      off_shelf_article
    end

    def self.off_shelf_materials
      CpsMaterial.enabled.where("end_date < '#{Date.today + 2}'").update_all(enabled: false)
    end

    def self.off_shelf_article
      cps_articles = CpsArticle.joins(:cps_materials).where("cps_materials.enabled='0' and cps_articles.enabled = '1' and cps_articles.status = 'passed'").
        group("cps_articles.id").having("count(cps_materials.id) > 0")
      cps_articles.each do |article|
        article.update_column(:enabled, false)  if article.cps_materials.size == 1
      end
    end
  end
end
