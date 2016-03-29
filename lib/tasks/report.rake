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
end