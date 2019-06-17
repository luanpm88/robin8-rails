module Campaigns
  module CampaignInviteAnalysis
    extend ActiveSupport::Concern

    def gender_analysis_of_invitee
      _ary = self.valid_invites.includes(:kol).collect{|ele| (ele.kol.present? and ele.kol.gender)}

      [
        {
          name: "man",
          ratio: (_ary.count > 0 ? 1.0 * _ary.count(1) / _ary.count : 0)
        },
        {
          name: "woman",
          ratio: (_ary.count > 0 ? 1.0 * _ary.count(2) / _ary.count : 0)
        }
      ]
    end

    def age_analysis_of_invitee
      _ary = self.valid_invites.includes(:kol).collect{|ele| ele.kol.age}.compact

      [[0, 20], [20, 30],[30, 40], [40, 50], [50, 60], [60, 100]].map do |min, max|

        age_count = _ary.count{|ele| ele > min and ele <= max }

        ratio = _ary.count > 0 ? 1.0 * age_count / _ary.count : 0
        {
          name: "#{min}age-#{max}age",
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
          name: tag.name,
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

        provinces = result.map{|r| r[:province_name]}

        if provinces.include? province.name
          index = provinces.index(province.name)
          result[index][:city] << {city_code: city.name_en, city_name: city.short_name, kols_count: cc[1]}
          result[index][:province_kols_count] = result[index][:city].map{|city| city[:kols_count]}.sum
        else
          cities = []
          cities << {city_code: city.name_en, city_name: city.short_name, kols_count: cc[1]}
          province_kols_count = cities.map{|city| city[:kols_count]}.sum
          result << {province_name: province.name, province_code: province.name_en, province_short_name:province.short_name, province_kols_count: province_kols_count, city: cities}
        end
      end

      result
    end

  end
end
