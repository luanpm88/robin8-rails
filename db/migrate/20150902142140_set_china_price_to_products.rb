class SetChinaPriceToProducts < ActiveRecord::Migration
  def change
    prices_array = {'basic-monthly' => 129.92, 'basic-annual' => 1230.80, 'business-monthly' => 1223.97, 'business-annual' => 12308.04, 'enterprise-monthly' => 2728.28, 'enterprise-annual' => 28718.76, 'pro-monthly' => 2044.50, 'pro-annual' => 20513.40, 'premium-monthly' => 3412.06, 'premium-annual' => 34052.24, 'ultra-monthly' => 8205.36, 'ultra-annual' => 82053.60, 'media_moitoring' => 68.38, 'newsroom' => 136.76, 'press_release' => 13.68, 'seat' => 676.94, 'smart_release' => 512.84, '5_smart_releases' => 2393.23, '10_smart_releases' => 4444.57, '20_smart_releases' => 8205.36, 'accesswire_distribution' => 1196.62, 'myprgenie_web_distribution' => 273.51, 'pr_newswire_distribution' => 3077.01, 'newbasic-monthly' => 341.89, 'newbusiness-monthly' => 1367.56, 'newenterprise-monthly' => 17094.50}
    Product.all.each do |p|
      if prices_array.has_key?(p.sku_id)
        p.update(:china_price => prices_array[p.sku_id])
      end
    end
  end
end
