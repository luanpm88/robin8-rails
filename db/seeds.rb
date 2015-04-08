#Seed industries

["Accounting","Airlines/Aviation","Alternative Dispute Resolution","Alternative Medicine","Animation","Apparel & Fashion","Architecture & Planning","Arts and Crafts","Automotive","Aviation & Aerospace","Banking","Biotechnology","Broadcast Media","Building Materials",
 "Business Supplies and Equipment","Capital Markets","Chemicals","Civic & Social Organization","Civil Engineering","Cleaning/Janitorial","Commercial Real Estate","Computer & Network Security","Computer Games","Computer Hardware","Computer Networking","Computer Software",
 "Construction","Consumer Electronics","Consumer Goods","Consumer Services","Cosmetics","Dairy","Defense & Space","Design","E-Learning","Education Management","Electrical/Electronic Manufacturing","Entertainment","Environmental Services","Events Services","Executive Office",
 "Facilities Services","Farming","Financial Services","Fine Art","Fishery","Food & Beverages","Food Production","Franchise Opportunities","Fund-Raising","Furniture","Gambling & Casinos","Glass, Ceramics & Concrete","Government Administration","Government Relations",
 "Graphic Design","Health, Wellness and Fitness","Higher Education","Hospital & Health Care","Hospitality","Human Resources","Import and Export","Individual & Family Services","Industrial Automation","Information Services","Information Technology and Services","Insurance",
 "International Affairs","International Trade and Development","Internet","Investment Banking","Investment Management","Judiciary","Law Enforcement","Law Practice","Legal Services","Legislative Office","Leisure, Travel & Tourism","Libraries","Logistics and Supply Chain",
 "Luxury Goods & Jewelry","Machinery","Management Consulting","Maritime","Market Research","Marketing and Advertising","Mechanical or Industrial Engineering","Media Production","Medical Devices","Medical Practice","Mental Health Care","Military","Mining & Metals",
 "Motion Pictures and Film","Museums and Institutions","Music","Nanotechnology","Newspapers","Non-Profit Organization Management","Oil & Energy","Online Media","Outsourcing/Offshoring","Package/Freight Delivery","Packaging and Containers","Paper & Forest Products",
 "Performing Arts","Pharmaceuticals","Philanthropy","Photography","Plastics","Political Organization","Primary/Secondary Education","Printing","Professional Training & Coaching","Program Development","Public Policy","Public Relations and Communications",
 "Public Safety","Publishing","Railroad Manufacture","Ranching","Real Estate","Recreational Facilities and Services","Religious Institutions","Renewable & Environment","Research","Restaurants","Retail","Security and Investigations","Semiconductors","Shipbuilding",
 "Sporting Goods","Sports","Staffing and Recruiting","Supermarkets","Telecommunications","Textiles","Think Tanks","Tobacco","Translation and Localization","Transportation/Trucking/Railroad","Utilities","Venture Capital & Private Equity","Veterinary","Warehousing",
 "Wholesale","Wine and Spirits","Wireless","Writing and Editing"].each do |name|
  Industry.find_or_create_by name: name
end

Feature.create(name: "Seat",is_active: true,slug: "seat")
Feature.create(name: "Newsroom",is_active: true,slug: "newsroom")
Feature.create(name: "Press Release",is_active: true,slug: "press_release")
Feature.create(name: "Smart Release",is_active: true,slug: "smart_release")
Feature.create(name: "Streams - Media Monitoring",is_active: true,slug: "media_monitoring")
Feature.create(name: "Personal Media List",is_active: true,slug: "personal_media_list")
Feature.create(name: "MyPRGenie Web Distribution",is_active: true,slug: "myprgenie_web_distribution")
Feature.create(name: "Accesswire Distribution",is_active: true,slug: "accesswire_distribution")
Feature.create(name: "PR Newswire Distribution",is_active: true,slug: "pr_newswire_distribution")


if Rails.env == 'development'
  p = Package.create(slug: "basic-monthly", is_active: true, price: 19.00,
                     interval: 30, name: "Basic Monthly", description: "basic monthly subscription", sku_id:2257477,is_package: true)
  p.product_features.create!(feature_id:Feature.find_by_slug("seat").id,validity: 0,count: 1 )
  p.product_features.create!(feature_id:Feature.find_by_slug("newsroom").id,validity: 0,count: 1 )
  p.product_features.create!(feature_id:Feature.find_by_slug("press_release").id,validity: 30,count: 5 )
  p.product_features.create!(feature_id:Feature.find_by_slug("smart_release").id,validity: 30,count: 3 )
  p.product_features.create!(feature_id:Feature.find_by_slug("media_monitoring").id,validity: 0,count: 3 )


  p = Package.create(slug: "basic-annual", is_active: true, price: 180.00,
                 interval: 365, name: "Basic Annual", description: "basic annual subscription", sku_id: 2257479,is_package: true)
  p.product_features.create!(feature_id:Feature.find_by_slug("seat").id,validity: 0,count: 1 )
  p.product_features.create!(feature_id:Feature.find_by_slug("newsroom").id,validity: 0,count: 1 )
  p.product_features.create!(feature_id:Feature.find_by_slug("press_release").id,validity: 30,count: 5 )
  p.product_features.create!(feature_id:Feature.find_by_slug("smart_release").id,validity: 30,count: 3 )
  p.product_features.create!(feature_id:Feature.find_by_slug("media_monitoring").id,validity: 0,count: 3 )


  p = Package.create(slug: "business-monthly", is_active: true, price: 179.00,
                 interval: 30, name: "Business Monthly", description: "business monthly subscription", sku_id: 2257703,is_package: true)
  p.product_features.create!(feature_id:Feature.find_by_slug("seat").id,validity: 0,count: 1 )
  p.product_features.create!(feature_id:Feature.find_by_slug("newsroom").id,validity: 0,count: 1 )
  p.product_features.create!(feature_id:Feature.find_by_slug("press_release").id,validity: 30,count: 10 )
  p.product_features.create!(feature_id:Feature.find_by_slug("smart_release").id,validity: 30,count: 5 )
  p.product_features.create!(feature_id:Feature.find_by_slug("media_monitoring").id,validity: 0,count: 5 )
  p.product_features.create!(feature_id:Feature.find_by_slug("personal_media_list").id,validity: 0,count: 5 )


  p = Package.create(slug: "business-annual", is_active: true, price: 1800.00,
                 interval: 365, name: "Business Annual", description: "business annual subscription", sku_id:2257705,is_package: true)
  p.product_features.create!(feature_id:Feature.find_by_slug("seat").id,validity: 0,count: 1 )
  p.product_features.create!(feature_id:Feature.find_by_slug("newsroom").id,validity: 0,count: 1 )
  p.product_features.create!(feature_id:Feature.find_by_slug("press_release").id,validity: 30,count: 10 )
  p.product_features.create!(feature_id:Feature.find_by_slug("smart_release").id,validity: 30,count: 5 )
  p.product_features.create!(feature_id:Feature.find_by_slug("media_monitoring").id,validity: 0,count: 5 )
  p.product_features.create!(feature_id:Feature.find_by_slug("personal_media_list").id,validity: 0,count: 5 )


  p = Package.create(slug: "enterprise-monthly", is_active: true, price: 399.00,
                 interval: 30, name: "Enterprise Monthly", description: "enterprise monthly subscription", sku_id: 2257707,is_package: true)
  p.product_features.create!(feature_id:Feature.find_by_slug("seat").id,validity: 0,count: 1 )
  p.product_features.create!(feature_id:Feature.find_by_slug("newsroom").id,validity: 0,count: 1 )
  p.product_features.create!(feature_id:Feature.find_by_slug("press_release").id,validity: 30,count: 30 )
  p.product_features.create!(feature_id:Feature.find_by_slug("smart_release").id,validity: 30,count: 15 )
  p.product_features.create!(feature_id:Feature.find_by_slug("media_monitoring").id,validity: 0,count: 25 )
  p.product_features.create!(feature_id:Feature.find_by_slug("personal_media_list").id,validity: 0,count: 20 )

  p = Package.create(slug: "enterprise-annual", is_active: true, price: 4200.00,
                 interval: 365, name: "Enterprise Annual", description: "enterprise annual subscription", sku_id: 2257709,is_package: true)
  p.product_features.create!(feature_id:Feature.find_by_slug("seat").id,validity: 0,count: 1 )
  p.product_features.create!(feature_id:Feature.find_by_slug("newsroom").id,validity: 0,count: 1 )
  p.product_features.create!(feature_id:Feature.find_by_slug("press_release").id,validity: 30,count: 30 )
  p.product_features.create!(feature_id:Feature.find_by_slug("smart_release").id,validity: 30,count: 15 )
  p.product_features.create!(feature_id:Feature.find_by_slug("media_monitoring").id,validity: 0,count: 25 )
  p.product_features.create!(feature_id:Feature.find_by_slug("personal_media_list").id,validity: 0,count: 20 )


  p = Package.create(slug: "pro-monthly", is_active: true, price: 299.00,
                 interval: 30, name: "Pro Monthly", description: "pro monthly subscription", sku_id:2257481,is_package: true)

  p.product_features.create!(feature_id:Feature.find_by_slug("seat").id,validity: 0,count: 1 )
  p.product_features.create!(feature_id:Feature.find_by_slug("newsroom").id,validity: 0,count: 5 )
  p.product_features.create!(feature_id:Feature.find_by_slug("press_release").id,validity: 30,count: 30 )
  p.product_features.create!(feature_id:Feature.find_by_slug("smart_release").id,validity: 30,count: 15 )
  p.product_features.create!(feature_id:Feature.find_by_slug("media_monitoring").id,validity: 0,count: 5 )
  p.product_features.create!(feature_id:Feature.find_by_slug("personal_media_list").id,validity: 0,count: 3 )

  p = Package.create(slug: "pro-annual", is_active: true, price: 3000.00,
                 interval: 365, name: "Pro Annual", description: "pro annual subscription", sku_id:2257483,is_package: true)
  p.product_features.create!(feature_id:Feature.find_by_slug("seat").id,validity: 0,count: 1 )
  p.product_features.create!(feature_id:Feature.find_by_slug("newsroom").id,validity: 0,count: 5 )
  p.product_features.create!(feature_id:Feature.find_by_slug("press_release").id,validity: 30,count: 30 )
  p.product_features.create!(feature_id:Feature.find_by_slug("smart_release").id,validity: 30,count: 15 )
  p.product_features.create!(feature_id:Feature.find_by_slug("media_monitoring").id,validity: 0,count: 5 )
  p.product_features.create!(feature_id:Feature.find_by_slug("personal_media_list").id,validity: 0,count: 3 )


  p = Package.create(slug: "premium-monthly", is_active: true, price: 499.00,
                 interval: 30, name: "Premium Monthly", description: "premium monthly subscription", sku_id: 2257485,is_package: true)
  p.product_features.create!(feature_id:Feature.find_by_slug("seat").id,validity: 0,count: 1 )
  p.product_features.create!(feature_id:Feature.find_by_slug("newsroom").id,validity: 0,count: 20 )
  p.product_features.create!(feature_id:Feature.find_by_slug("press_release").id,validity: 30,count: 75 )
  p.product_features.create!(feature_id:Feature.find_by_slug("smart_release").id,validity: 30,count: 45 )
  p.product_features.create!(feature_id:Feature.find_by_slug("media_monitoring").id,validity: 0,count: 10 )
  p.product_features.create!(feature_id:Feature.find_by_slug("personal_media_list").id,validity: 0,count: 5 )


  p = Package.create(slug: "premium-annual", is_active: true, price: 4980.00,
                 interval: 365, name: "Premium Annual", description: "premium annual subscription", sku_id: 2257487,is_package: true)
  p.product_features.create!(feature_id:Feature.find_by_slug("seat").id,validity: 0,count: 1 )
  p.product_features.create!(feature_id:Feature.find_by_slug("newsroom").id,validity: 0,count: 20 )
  p.product_features.create!(feature_id:Feature.find_by_slug("press_release").id,validity: 30,count: 75 )
  p.product_features.create!(feature_id:Feature.find_by_slug("smart_release").id,validity: 30,count: 45 )
  p.product_features.create!(feature_id:Feature.find_by_slug("media_monitoring").id,validity: 0,count: 10 )
  p.product_features.create!(feature_id:Feature.find_by_slug("personal_media_list").id,validity: 0,count: 5 )

  p = Package.create(slug: "ultra-monthly", is_active: true, price: 1200.00,
                 interval: 30, name: "Ultra Monthly", description: "ultra monthly subscription", sku_id: 2257711,is_package: true)
  p.product_features.create!(feature_id:Feature.find_by_slug("seat").id,validity: 0,count: 1 )
  p.product_features.create!(feature_id:Feature.find_by_slug("newsroom").id,validity: 0,count: 100 )
  p.product_features.create!(feature_id:Feature.find_by_slug("press_release").id,validity: 30,count: 400 )
  p.product_features.create!(feature_id:Feature.find_by_slug("smart_release").id,validity: 30,count: 200 )
  p.product_features.create!(feature_id:Feature.find_by_slug("media_monitoring").id,validity: 0,count: 25 )
  p.product_features.create!(feature_id:Feature.find_by_slug("personal_media_list").id,validity: 0,count: 10 )

  p = Package.create(slug: "ultra-annual", is_active: true, price: 12000.00,
                 interval: 365, name: "Ultra Annual", description: "ultra annual subscription", sku_id: 2257713,is_package: true)
  p.product_features.create!(feature_id:Feature.find_by_slug("seat").id,validity: 0,count: 1 )
  p.product_features.create!(feature_id:Feature.find_by_slug("newsroom").id,validity: 0,count: 100 )
  p.product_features.create!(feature_id:Feature.find_by_slug("press_release").id,validity: 30,count: 400 )
  p.product_features.create!(feature_id:Feature.find_by_slug("smart_release").id,validity: 30,count: 200 )
  p.product_features.create!(feature_id:Feature.find_by_slug("media_monitoring").id,validity: 0,count: 25 )
  p.product_features.create!(feature_id:Feature.find_by_slug("personal_media_list").id,validity: 0,count: 10 )


  ##AddONs
  # p = AddOn.create(name: "MyPRGenie Web Distribution (per release)", is_active: true, price: 40.00,
  #                    description: "MyPRGenie Web Distribution (per release)", sku_id: 2258429,interval: 0,slug: 'myprgenie_web_distribution')
  # p.product_features.create!(feature_id:Feature.find_by_slug("myprgenie_web_distribution").id,validity: 360,count: 1 )

end

if Rails.env.production?
  p = Package.create(slug: "basic-monthly", is_active: true, price: 19.00,
                 interval: 30, name: "Basic Monthly", description: "basic monthly subscription", sku_id:3262130,is_package: true)
  p.product_features.create!(feature_id:Feature.find_by_slug("seat").id,validity: 0,count: 1 )
  p.product_features.create!(feature_id:Feature.find_by_slug("newsroom").id,validity: 0,count: 1 )
  p.product_features.create!(feature_id:Feature.find_by_slug("press_release").id,validity: 30,count: 5 )
  p.product_features.create!(feature_id:Feature.find_by_slug("smart_release").id,validity: 30,count: 3 )
  p.product_features.create!(feature_id:Feature.find_by_slug("media_monitoring").id,validity: 0,count: 3 )


  p = Package.create(slug: "basic-annual", is_active: true, price: 180.00,
                 interval: 365, name: "Basic Annual", description: "basic annual subscription", sku_id: 3262134,is_package: true)
  p.product_features.create!(feature_id:Feature.find_by_slug("seat").id,validity: 0,count: 1 )
  p.product_features.create!(feature_id:Feature.find_by_slug("newsroom").id,validity: 0,count: 1 )
  p.product_features.create!(feature_id:Feature.find_by_slug("press_release").id,validity: 30,count: 5 )
  p.product_features.create!(feature_id:Feature.find_by_slug("smart_release").id,validity: 30,count: 3 )
  p.product_features.create!(feature_id:Feature.find_by_slug("media_monitoring").id,validity: 0,count: 3 )


  p = Package.create(slug: "business-monthly", is_active: true, price: 179.00,
                 interval: 30, name: "Business Monthly", description: "business monthly subscription", sku_id: 3262138,is_package: true)
  p.product_features.create!(feature_id:Feature.find_by_slug("seat").id,validity: 0,count: 1 )
  p.product_features.create!(feature_id:Feature.find_by_slug("newsroom").id,validity: 0,count: 1 )
  p.product_features.create!(feature_id:Feature.find_by_slug("press_release").id,validity: 30,count: 10 )
  p.product_features.create!(feature_id:Feature.find_by_slug("smart_release").id,validity: 30,count: 5 )
  p.product_features.create!(feature_id:Feature.find_by_slug("media_monitoring").id,validity: 0,count: 5 )
  p.product_features.create!(feature_id:Feature.find_by_slug("personal_media_list").id,validity: 0,count: 5 )

  p = Package.create(slug: "business-annual", is_active: true, price: 1800.00,
                 interval: 365, name: "Business Annual", description: "business annual subscription", sku_id:3262152,is_package: true)
  p.product_features.create!(feature_id:Feature.find_by_slug("seat").id,validity: 0,count: 1 )
  p.product_features.create!(feature_id:Feature.find_by_slug("newsroom").id,validity: 0,count: 1 )
  p.product_features.create!(feature_id:Feature.find_by_slug("press_release").id,validity: 30,count: 10 )
  p.product_features.create!(feature_id:Feature.find_by_slug("smart_release").id,validity: 30,count: 5 )
  p.product_features.create!(feature_id:Feature.find_by_slug("media_monitoring").id,validity: 0,count: 5 )
  p.product_features.create!(feature_id:Feature.find_by_slug("personal_media_list").id,validity: 0,count: 5 )


  p = Package.create(slug: "enterprise-monthly", is_active: true, price: 399.00,
                 interval: 30, name: "Enterprise Monthly", description: "enterprise monthly subscription", sku_id: 3262154,is_package: true)
  p.product_features.create!(feature_id:Feature.find_by_slug("seat").id,validity: 0,count: 1 )
  p.product_features.create!(feature_id:Feature.find_by_slug("newsroom").id,validity: 0,count: 1 )
  p.product_features.create!(feature_id:Feature.find_by_slug("press_release").id,validity: 30,count: 30 )
  p.product_features.create!(feature_id:Feature.find_by_slug("smart_release").id,validity: 30,count: 15 )
  p.product_features.create!(feature_id:Feature.find_by_slug("media_monitoring").id,validity: 0,count: 25 )
  p.product_features.create!(feature_id:Feature.find_by_slug("personal_media_list").id,validity: 0,count: 20 )



  p = Package.create(slug: "enterprise-annual", is_active: true, price: 4200.00,
                 interval: 365, name: "Enterprise Annual", description: "enterprise annual subscription", sku_id: 3262156,is_package: true)

  p.product_features.create!(feature_id:Feature.find_by_slug("seat").id,validity: 0,count: 1 )
  p.product_features.create!(feature_id:Feature.find_by_slug("newsroom").id,validity: 0,count: 1 )
  p.product_features.create!(feature_id:Feature.find_by_slug("press_release").id,validity: 30,count: 30 )
  p.product_features.create!(feature_id:Feature.find_by_slug("smart_release").id,validity: 30,count: 15 )
  p.product_features.create!(feature_id:Feature.find_by_slug("media_monitoring").id,validity: 0,count: 25 )
  p.product_features.create!(feature_id:Feature.find_by_slug("personal_media_list").id,validity: 0,count: 20 )



  p = Package.create(slug: "pro-monthly", is_active: true, price: 299.00,
                 interval: 30, name: "Pro Monthly", description: "pro monthly subscription", sku_id:3262158,is_package: true)
  p.product_features.create!(feature_id:Feature.find_by_slug("seat").id,validity: 0,count: 1 )
  p.product_features.create!(feature_id:Feature.find_by_slug("newsroom").id,validity: 0,count: 5 )
  p.product_features.create!(feature_id:Feature.find_by_slug("press_release").id,validity: 30,count: 30 )
  p.product_features.create!(feature_id:Feature.find_by_slug("smart_release").id,validity: 30,count: 15 )
  p.product_features.create!(feature_id:Feature.find_by_slug("media_monitoring").id,validity: 0,count: 5 )
  p.product_features.create!(feature_id:Feature.find_by_slug("personal_media_list").id,validity: 0,count: 3 )

  p = Package.create(slug: "pro-annual", is_active: true, price: 3000.00,
                 interval: 365, name: "Pro Annual", description: "pro annual subscription", sku_id:3262160,is_package: true)
  p.product_features.create!(feature_id:Feature.find_by_slug("seat").id,validity: 0,count: 1 )
  p.product_features.create!(feature_id:Feature.find_by_slug("newsroom").id,validity: 0,count: 5 )
  p.product_features.create!(feature_id:Feature.find_by_slug("press_release").id,validity: 30,count: 30 )
  p.product_features.create!(feature_id:Feature.find_by_slug("smart_release").id,validity: 30,count: 15 )
  p.product_features.create!(feature_id:Feature.find_by_slug("media_monitoring").id,validity: 0,count: 5 )
  p.product_features.create!(feature_id:Feature.find_by_slug("personal_media_list").id,validity: 0,count: 3 )


  p = Package.create(slug: "premium-monthly", is_active: true, price: 499.00,
                 interval: 30, name: "Premium Monthly", description: "premium monthly subscription", sku_id: 3262162,is_package: true)
  p.product_features.create!(feature_id:Feature.find_by_slug("seat").id,validity: 0,count: 1 )
  p.product_features.create!(feature_id:Feature.find_by_slug("newsroom").id,validity: 0,count: 20 )
  p.product_features.create!(feature_id:Feature.find_by_slug("press_release").id,validity: 30,count: 75 )
  p.product_features.create!(feature_id:Feature.find_by_slug("smart_release").id,validity: 30,count: 45 )
  p.product_features.create!(feature_id:Feature.find_by_slug("media_monitoring").id,validity: 0,count: 10 )
  p.product_features.create!(feature_id:Feature.find_by_slug("personal_media_list").id,validity: 0,count: 5 )

  p = Package.create(slug: "premium-annual", is_active: true, price: 4980.00,
                 interval: 365, name: "Premium Annual", description: "premium annual subscription", sku_id: 3262170,is_package: true)
  p.product_features.create!(feature_id:Feature.find_by_slug("seat").id,validity: 0,count: 1 )
  p.product_features.create!(feature_id:Feature.find_by_slug("newsroom").id,validity: 0,count: 20 )
  p.product_features.create!(feature_id:Feature.find_by_slug("press_release").id,validity: 30,count: 75 )
  p.product_features.create!(feature_id:Feature.find_by_slug("smart_release").id,validity: 30,count: 45 )
  p.product_features.create!(feature_id:Feature.find_by_slug("media_monitoring").id,validity: 0,count: 10 )
  p.product_features.create!(feature_id:Feature.find_by_slug("personal_media_list").id,validity: 0,count: 5 )


  p = Package.create(slug: "ultra-monthly", is_active: true, price: 1200.00,
                 interval: 30, name: "Ultra Monthly", description: "ultra monthly subscription", sku_id: 3262172,is_package: true)
  p.product_features.create!(feature_id:Feature.find_by_slug("seat").id,validity: 0,count: 1 )
  p.product_features.create!(feature_id:Feature.find_by_slug("newsroom").id,validity: 0,count: 100 )
  p.product_features.create!(feature_id:Feature.find_by_slug("press_release").id,validity: 30,count: 400 )
  p.product_features.create!(feature_id:Feature.find_by_slug("smart_release").id,validity: 30,count: 200 )
  p.product_features.create!(feature_id:Feature.find_by_slug("media_monitoring").id,validity: 0,count: 25 )
  p.product_features.create!(feature_id:Feature.find_by_slug("personal_media_list").id,validity: 0,count: 10 )

  p = Package.create(slug: "ultra-annual", is_active: true, price: 12000.00,
                 interval: 365, name: "Ultra Annual", description: "ultra annual subscription", sku_id: 3262174,is_package: true)
  p.product_features.create!(feature_id:Feature.find_by_slug("seat").id,validity: 0,count: 1 )
  p.product_features.create!(feature_id:Feature.find_by_slug("newsroom").id,validity: 0,count: 100 )
  p.product_features.create!(feature_id:Feature.find_by_slug("press_release").id,validity: 30,count: 400 )
  p.product_features.create!(feature_id:Feature.find_by_slug("smart_release").id,validity: 30,count: 200 )
  p.product_features.create!(feature_id:Feature.find_by_slug("media_monitoring").id,validity: 0,count: 25 )
  p.product_features.create!(feature_id:Feature.find_by_slug("personal_media_list").id,validity: 0,count: 10 )


end


if Rails.env.production?
  p = AddOn.create!(price:10 ,name: "Media Monitoring Stream (per month)", is_active: true, sku_id: 3264288,interval: 30,slug: "media_moitoring")
  p.product_features.create!(feature_id:Feature.find_by_slug("media_monitoring").id,validity: 30,count: 1 )

  p = AddOn.create!(price:20 ,name: "Newsroom (per month)", is_active: true, sku_id: 3264286,interval: 30,slug: "newsroom")
  p.product_features.create!(feature_id:Feature.find_by_slug("newsroom").id,validity: 30,count: 1 )

  p = AddOn.create!(price: 2,name: "Press Release Distribution (per release)", is_active: true, sku_id: 3264268,slug: "press_release")
  p.product_features.create!(feature_id:Feature.find_by_slug("press_release").id,validity: 360,count: 1 )

  p = AddOn.create!(price: 99,name: "Seat (per month)", is_active: true, sku_id: 3264284,interval: 30,slug: "seat")
  p.product_features.create!(feature_id:Feature.find_by_slug("seat").id,validity: 30,count: 1 )

  p = AddOn.create!(price: 75,name: "Smart Release Distribution (per release)", is_active: true, sku_id: 3264270,slug: "smart_release")
  p.product_features.create!(feature_id:Feature.find_by_slug("smart_release").id,validity: 360,count: 1 )

  p = AddOn.create!(price: 350,name: "5 Smart Release Distribution (per 5 releases)", is_active: true, sku_id: 3264272,slug: "5_smart_releases")
  p.product_features.create!(feature_id:Feature.find_by_slug("smart_release").id,validity: 360,count: 5 )

  p = AddOn.create!(price: 650,name: "10 Smart Release Distribution (per 10 releases)", is_active: true, sku_id: 3264274,slug: "10_smart_releases")
  p.product_features.create!(feature_id:Feature.find_by_slug("smart_release").id,validity: 360,count: 10 )

  p = AddOn.create!(price: 1200,name: "20 Smart Release Distribution (per 20 releases)", is_active: true, sku_id: 3264276,slug: "20_smart_releases")
  p.product_features.create!(feature_id:Feature.find_by_slug("smart_release").id,validity: 360,count: 20 )

  p = AddOn.create!(price:40,name: "Accesswire Distribution (per release)", is_active: true, sku_id: 3264280,slug: "accesswire_distribution")
  p.product_features.create!(feature_id:Feature.find_by_slug("accesswire_distribution").id,validity: 360,count: 1 )

  p = AddOn.create!(price: 175,name: "MyPRGenie Web Distribution (per release)", is_active: true, sku_id: 3264278,slug: "myprgenie_web_distribution")
  p.product_features.create!(feature_id:Feature.find_by_slug("myprgenie_web_distribution").id,validity: 360,count: 1 )

  p = AddOn.create!(price: 450,name: "PR Newswire Distribution (per release)", is_active: true, sku_id: 3264282,slug: "pr_newswire_distribution")
  p.product_features.create!(feature_id:Feature.find_by_slug("pr_newswire_distribution").id,validity: 360,count: 1 )
end

