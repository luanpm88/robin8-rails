# encoding: utf-8

namespace :idfa_check  do
  
  desc "Check IDFA to see what channels the KOLs come from "

  task :check_idfa, [:fileName, :startTime] => [:environment] do |t, args|
    
    # Read a csv file from 小鱼 or others, where the second column is the IDFA list
    # c = CSV.read('config/data_attrs/170524_xiaoyu.csv', 'rb') { |r| puts r }
    c = CSV.read(args[:fileName], 'rb') { |r| puts r }
    
    # Check if the KOLs are new or registered before the campaign starts.
    # campaign_start_time = DateTime.new(2017, 05, 22, 19, 30, 00)
    campaign_start_time = DateTime.parse(args[:startTime])
    #puts "Args were: #{args}"
    
    idfas = c[1..-1].map { |r| r[1] }
    kol_from_this_channel = Kol.where(IDFA: idfas)
    new_kol = kol_from_this_channel.where('created_at > ?',campaign_start_time)
    took_campaign_count = new_kol.where("historical_income > ?", 1).count
    all_took_campaign_count = kol_from_this_channel.where("historical_income > ?", 1).count
    
    puts "Number of total Robin8 user within campaign (including previous registered user): #{kol_from_this_channel.count}"
    puts "Number of total Robin8 user who took campaign (including previous registered user): #{all_took_campaign_count}"
    puts "Number of new KOLs registered: #{new_kol.count}"
    puts "Number of new KOLs taken campaigns: #{took_campaign_count}"
    puts "\nIDFA Checked."
  end
end
