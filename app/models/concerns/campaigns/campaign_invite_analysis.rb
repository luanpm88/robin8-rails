module Campaigns
  module CampaignInviteAnalysis
    extend ActiveSupport::Concern

    def gender_analysis_of_invitee
      male_count   = self.kols.where(gender: 1).count
      female_count = self.kols.where(gender: 2).count
      total_count = male_count + female_count

      [
        {
          name: "男性",
          ratio: (total_count > 0 ? 1.0 * male_count / total_count : 0)
        },
        {
          name: "女性",
          ratio: (total_count > 0 ? 1.0 * female_count / total_count : 0)
        }
      ]
    end

    def age_analysis_of_invitee
      total_count = self.kols.where.not(age: nil).count

      [[0, 20], [20, 40], [40, 60], [60, 100]].map do |min, max|
        age_count = self.kols.where("age > ? AND age <= ?", min, max).count

        ratio = total_count > 0 ? 1.0 * age_count / total_count : 0
        {
          name: "#{min}岁-#{max}岁",
          count: age_count,
          ratio: ratio
        }
      end
    end

    def tag_analysis_of_invitee
      tag_counts = self.kol_tags.joins(:tag).group(:tag_id).count.sort_by {|k, v| v}.reverse

      tag_counts = tag_counts[0, 5]
      total_count = tag_counts.inject(0) do |sum, tc|
        sum += tc[1]
      end

      tag_counts.map do |tc|
        tag = Tag.find(tc[0])

        {
          name: tag.label,
          code: tag.name,
          count: tc[1],
          ratio: (total_count > 0 ? 1.0 * tc[1] / total_count : 0)
        }
      end
    end

    def region_analysis_of_invitee
      city_counts = self.kols.group(:app_city).count
      city_counts.map do |cc|
        city = City.where(name_en: cc[0]).take
        next unless city
        province = city.province
        next unless province

        {
          city_name: city.short_name,
          city_code: city.name_en,
          province_name: province.name,
          province_short_name: province.short_name,
          province_code: province.name_en
        }
      end.compact.sort_by { |c| c[:province_code] } rescue []
    end

    def region_analysis_of_invitee_v2
      city_counts = self.kols.group(:app_city).count
      provinces = []
      cities = []
      result = []
      city_counts.map do |cc|
        city = City.where(name_en: cc[0]).take
        next unless city
        province = city.province
        next unless province

        province_name = province.name
        city_name = city.short_name
        unless provinces.include? province_name
          cities = []
          provinces << province_name
          cities << {city_code: city.name_en, city_name: city.short_name}
          result << {province_name: province_name, province_code: province.name_en, province_short_name:province.short_name, city: cities}
        else
          result.map do |r|
            if r[:province_name] == province_name
              unless r[:city].include?({city_code: city.name_en, city_name: city.short_name})
                r[:city] << {city_code: city.name_en, city_name: city.short_name}
              end
            end
          end
        end
      end
      result
    end

  end
end
