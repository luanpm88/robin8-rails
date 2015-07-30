if Rails.env.production?
  puts "nothing here"
else
  p = Package.create(slug: "newbasic-monthly", is_active: true, price: 50.00,
                     interval: 30, name: "Basic Monthly", description: "basic monthly subscription",
                     sku_id:2264951, is_package: true)
  p.product_features.create!(feature_id: Feature.find_by_slug("seat").id, validity: 0, count: 1 )
  p.product_features.create!(feature_id: Feature.find_by_slug("newsroom").id, validity: 0, count: 1 )
  p.product_features.create!(feature_id: Feature.find_by_slug("press_release").id, validity: 30, count: 5 )
  p.product_features.create!(feature_id: Feature.find_by_slug("smart_release").id, validity: 30, count: 5 )
  p.product_features.create!(feature_id: Feature.find_by_slug("media_monitoring").id, validity: 0, count: 3 )
  p.product_features.create!(feature_id: Feature.find_by_slug("personal_media_list").id, validity: 0, count: 1 )

  p = Package.create(slug: "newbusiness-monthly", is_active: true, price: 200.00,
                     interval: 30, name: "Business Monthly", description: "business monthly subscription",
                     sku_id:2264953, is_package: true)
  p.product_features.create!(feature_id: Feature.find_by_slug("seat").id, validity: 0, count: 5 )
  p.product_features.create!(feature_id: Feature.find_by_slug("newsroom").id, validity: 0, count: 5 )
  p.product_features.create!(feature_id: Feature.find_by_slug("press_release").id, validity: 30, count: 10 )
  p.product_features.create!(feature_id: Feature.find_by_slug("smart_release").id, validity: 30, count: 10 )
  p.product_features.create!(feature_id: Feature.find_by_slug("media_monitoring").id, validity: 0, count: 10 )
  p.product_features.create!(feature_id: Feature.find_by_slug("personal_media_list").id, validity: 0, count: 5 )

  p = Package.create(slug: "newenterprise-monthly", is_active: true, price: 2500.00,
                     interval: 30, name: "Entereprise Monthly", description: "enterprise monthly subscription",
                     sku_id:2264955, is_package: true)
  p.product_features.create!(feature_id: Feature.find_by_slug("seat").id, validity: 0, count: 75 )
  p.product_features.create!(feature_id: Feature.find_by_slug("newsroom").id, validity: 0, count: 75 )
  p.product_features.create!(feature_id: Feature.find_by_slug("press_release").id, validity: 30, count: 200 )
  p.product_features.create!(feature_id: Feature.find_by_slug("smart_release").id, validity: 30, count: 200 )
  p.product_features.create!(feature_id: Feature.find_by_slug("media_monitoring").id, validity: 0, count: 9999 )
  p.product_features.create!(feature_id: Feature.find_by_slug("personal_media_list").id, validity: 0, count: 9999 )
end

