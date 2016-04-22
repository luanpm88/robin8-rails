require 'rest-client'
namespace :report do
  desc "Generates Redis localization from yaml files"
  task generator: :environment do
    JuheService = "http://apis.juhe.cn/mobile/get"
    JuheKey = "51fe8f87af9aa1277eae34e508e28596"

    def get_city phone
      return unless phone.to_s.size == 11
      respond_json = RestClient.get JuheService, {:params => {:key => JuheKey, :phone => phone}, :timeout => 0.8 }       rescue ""
      respond = JSON.parse respond_json

      if respond["resultcode"] == "200"
        city = respond["result"]["city"]
      end
      return city
    end

    @kols = Kol.limit(100)
    csv_string = CsvShaper.encode do |csv|
      csv.headers :id, :created_at, :updated_at, :first_name, :last_name, :mobile_number, :city, :gender, :provider, :social_name, :social_uid

      csv.rows @kols do |csv, kol|
        city = kol.phone_city.present? ?  kol.phone_city : get_city(kol.mobile_number)
        options = []

        if city.present?
          kol.update(:phone_city => city)
        end
        
        %w(id created_at updated_at first_name last_name mobile_number).each do |attr|
          csv.cell attr
        end

        csv.cell :city, city

        %w(gender provider social_name social_uid).each do |attr|
          csv.cell attr
        end
      end
    end
    file = File.open("report_#{Date.today}.csv", 'w')
    file.write(csv_string)
    file.close
  end

  desc "Generates Redis localization from yaml files"
  task :campain_show_list_for_campaign do
    
  end

  desc "生成新建recruit 的城市列表"
  task :generate_cities_for_new_recruit do
    binding.pry
    new_lines = []
    File.new("#{Rails.root}/config/selector_city.txt").readlines.each do |line|
      line = line.strip
      if line.include?("=")
        address = line.match(/\p{Han}+/).to_s
      else
        new_lines << line
      end
    end
  end

  desc "每一天的 每个渠道的注册数目去掉重复的个数(在同一个设备 注册多个时间号， 只算首次的时间)"
  task :stat_source_of_kol do
    stats = {}
    kols = Kol.where("created_at > ?", "2016-3-28".to_time)
    kols.each do |kol|
      
    end
  end
end