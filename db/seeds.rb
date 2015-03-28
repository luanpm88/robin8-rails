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

if Rails.env == 'development'
  Package.create(slug: "basic-monthly", is_active: true, price: 19.00,
                 interval: 30, name: "Basic Monthly", description: "basic monthly subscription", sku_id:2257477)
  Package.create(slug: "basic-annual", is_active: true, price: 180.00,
                 interval: 365, name: "Basic Annual", description: "basic annual subscription", sku_id: 2257479)
  Package.create(slug: "business-monthly", is_active: true, price: 179.00,
                 interval: 30, name: "Business Monthly", description: "business monthly subscription", sku_id: 2257703)
  Package.create(slug: "business-annual", is_active: true, price: 1800.00,
                 interval: 365, name: "Business Annual", description: "business annual subscription", sku_id:2257705)
  Package.create(slug: "enterprise-monthly", is_active: true, price: 399.00,
                 interval: 30, name: "Enterprise Monthly", description: "enterprise monthly subscription", sku_id: 2257707)
  Package.create(slug: "enterprise-annual", is_active: true, price: 4200.00,
                 interval: 365, name: "Enterprise Annual", description: "enterprise annual subscription", sku_id: 2257709)
  Package.create(slug: "pro-monthly", is_active: true, price: 299.00,
                 interval: 30, name: "Pro Monthly", description: "pro monthly subscription", sku_id:2257481)
  Package.create(slug: "pro-annual", is_active: true, price: 3000.00,
                 interval: 365, name: "Pro Annual", description: "pro annual subscription", sku_id:2257483)
  Package.create(slug: "premium-monthly", is_active: true, price: 499.00,
                 interval: 30, name: "Premium Monthly", description: "premium monthly subscription", sku_id: 2257485)
  Package.create(slug: "premium-annual", is_active: true, price: 4980.00,
                 interval: 365, name: "Premium Annual", description: "premium annual subscription", sku_id: 2257487)
  Package.create(slug: "ultra-monthly", is_active: true, price: 1200.00,
                 interval: 30, name: "Ultra Monthly", description: "ultra monthly subscription", sku_id: 2257711)
  Package.create(slug: "ultra-annual", is_active: true, price: 12000.00,
                 interval: 365, name: "Ultra Annual", description: "ultra annual subscription", sku_id: 2257713)
end

if Rails.env.production?
  Package.create(slug: "basic-monthly", is_active: true, price: 19.00,
                 interval: 30, name: "Basic Monthly", description: "basic monthly subscription", sku_id:3262130)
  Package.create(slug: "basic-annual", is_active: true, price: 180.00,
                 interval: 365, name: "Basic Annual", description: "basic annual subscription", sku_id: 3262134)
  Package.create(slug: "business-monthly", is_active: true, price: 179.00,
                 interval: 30, name: "Business Monthly", description: "business monthly subscription", sku_id: 3262138)
  Package.create(slug: "business-annual", is_active: true, price: 1800.00,
                 interval: 365, name: "Business Annual", description: "business annual subscription", sku_id:3262152)
  Package.create(slug: "enterprise-monthly", is_active: true, price: 399.00,
                 interval: 30, name: "Enterprise Monthly", description: "enterprise monthly subscription", sku_id: 3262154)
  Package.create(slug: "enterprise-annual", is_active: true, price: 4200.00,
                 interval: 365, name: "Enterprise Annual", description: "enterprise annual subscription", sku_id: 3262156)
  Package.create(slug: "pro-monthly", is_active: true, price: 299.00,
                 interval: 30, name: "Pro Monthly", description: "pro monthly subscription", sku_id:3262158)
  Package.create(slug: "pro-annual", is_active: true, price: 3000.00,
                 interval: 365, name: "Pro Annual", description: "pro annual subscription", sku_id:3262160)
  Package.create(slug: "premium-monthly", is_active: true, price: 499.00,
                 interval: 30, name: "Premium Monthly", description: "premium monthly subscription", sku_id: 3262162)
  Package.create(slug: "premium-annual", is_active: true, price: 4980.00,
                 interval: 365, name: "Premium Annual", description: "premium annual subscription", sku_id: 3262170)
  Package.create(slug: "ultra-monthly", is_active: true, price: 1200.00,
                 interval: 30, name: "Ultra Monthly", description: "ultra monthly subscription", sku_id: 3262172)
  Package.create(slug: "ultra-annual", is_active: true, price: 12000.00,
                 interval: 365, name: "Ultra Annual", description: "ultra annual subscription", sku_id: 3262174)
end

if Rails.env.development?
  AddOn.create(name: "MyPRGenie Web Distribution (per release)", is_active: true, price: 40.00,
               validity: 30, description: "MyPRGenie Web Distribution (per release)", sku_id: 2258429)
end

if Rails.env.production?
  AddOn.create(price:10 ,name: "1 Media Montering Stream", is_active: true, sku_id: 3264288,count: 1,validity: 30,is_recurring: true, recurring_interval: 30)

  AddOn.create(price:20 ,name: "1 Newsroom", is_active: true, sku_id: 3264286,count: 1,validity: 30,is_recurring: true, recurring_interval: 30)

  AddOn.create(price: 2,name: "1 Regular Press Release Distribution", is_active: true, sku_id: 3264268,count: 1)

  AddOn.create(price: 99,name: "1 Seat", is_active: true, sku_id: 3264284,count: 1,validity: 30,is_recurring: true, recurring_interval: 30)

  AddOn.create(price: 75,name: "1 Smart Release Distribution", is_active: true, sku_id: 3264270,count: 1)

  AddOn.create(price: 350,name: "5 Smart Release Distribution", is_active: true, sku_id: 3264272,count: 5)

  AddOn.create(price: 650,name: "10 Smart Release Distribution", is_active: true, sku_id: 3264274,count: 10)

  AddOn.create(price: 1200,name: "20 Smart Release Distribution", is_active: true, sku_id: 3264276,count: 20)

  AddOn.create(price:40,name: "Newswire: Accesswire Distribution", is_active: true, sku_id: 3264280,count: 1)

  AddOn.create(price: 175,name: "Newswire: MyPRGenie Web Distribution", is_active: true, sku_id: 3264278,count: 1)

  AddOn.create(price: 450,name: "Newswire: PR Newswire Distribution", is_active: true, sku_id: 3264282,count: 1)
end