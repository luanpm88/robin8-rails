user = User.last
if user
  7.times do |t|
    @news_room = NewsRoom.create!(
      user_id: user.id,
      company_name: "Company_#{t}",
      subdomain_name: "subdomain_#{user.email}_#{t}",
      description: 'Donec id elit non mexiti porta gravida at eget metus. Fusce dapibus, tellus ac cursus commodo, tortor mauris condimentum nibh, ut fermentum massa justo sit amet risus. Etiam porta sem malesuada magna mollis euismod. Donec sed odio dui.',
      email: "aaa@aaa_#{t}.aaa",
      room_type: 'Privately Held',
      tags: "asdasda, asd a sd,qqqq, normal thing",
      size: '11-50 employees'
    )
  end
end

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
    Industry.create! name: name
  end

news_room = NewsRoom.last
if user
  15.times do |t|
    user.releases.create!(
      title: "Title #{t}",
      text: 'Donec id elit non mexiti porta gravida at eget metus. Fusce dapibus, tellus ac cursus commodo, tortor mauris condimentum nibh, ut fermentum massa justo sit amet risus. Etiam porta sem malesuada magna mollis euismod. Donec sed odio dui.',
      news_room_id: news_room.try(:id)
    )
  end
end