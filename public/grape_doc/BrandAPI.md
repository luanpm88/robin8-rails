### BrandAPI



#### GET /v1/user/campaigns

 Get campaigns current user owns



#### GET /v1/user

 Get current user profile



#### PUT /v1/user

 Update current user profile

**Parameters:** 


 - name (String) (*required*)

 - real\_name (String) (*required*)

 - description (String) (*required*)

 - keywords (String) (*required*)

 - url (String)



#### PUT /v1/user/password

 Update current user password

**Parameters:** 


 - password (String) (*required*)

 - new\_password (String) (*required*)

 - new\_password\_confirmation (String) (*required*)



#### PUT /v1/user/avatar

 Update current user avatar

**Parameters:** 


 - avatar\_url (String) (*required*)



#### GET /v1/invoice\_receiver

 



#### POST /v1/invoice\_receiver

 

**Parameters:** 


 - name (String) (*required*)

 - phone\_number (String) (*required*)

 - address (String) (*required*)



#### PUT /v1/invoice\_receiver

 

**Parameters:** 


 - name (String) (*required*)

 - phone\_number (String) (*required*)

 - address (String) (*required*)



#### GET /v1/util/qiniu\_token

 Get Qiniu upload token



#### GET /v1/util/tags

 Get supported profession list



#### GET /v1/campaigns/short\_url

 Generate short url by origin url and identifier

**Parameters:** 


 - url (String) (*required*)

 - identifier (String) (*required*)



#### POST /v1/campaigns/analysis

 analysis link url

**Parameters:** 


 - url (String) (*required*)



#### GET /v1/campaigns/statistics\_clicks

 

**Parameters:** 


 - campaign\_id (String) (*required*)



#### GET /v1/campaigns/installs

 

**Parameters:** 


 - campaign\_id (String) (*required*)



#### GET /v1/campaigns/:id

 Return a campaign by id

**Parameters:** 


 - id (Integer) (*required*) : Campaign id 



#### POST /v1/campaigns/analysis\_build

 build new campaign by analysising link url

**Parameters:** 


 - url (String) (*required*)

 - per\_budget\_type (String) (*required*)



#### POST /v1/campaigns

 Create a campaign

**Parameters:** 


 - name (String) (*required*)

 - description (String) (*required*)

 - url (String) (*required*)

 - img\_url (String) (*required*)

 - budget (Float) (*required*)

 - per\_budget\_type (String) (*required*)

 - per\_action\_budget (Float) (*required*)

 - message (String)

 - start\_time (DateTime) (*required*)

 - deadline (DateTime) (*required*)

 - sub\_type (String) (*required*)

 - target (Hash) (*required*)

 - target\[age\] (String) (*required*)

 - target\[region\] (String) (*required*)

 - target\[gender\] (String) (*required*)

 - target\[tags\] (String) (*required*)

 - campaign\_action\_url (Hash)

 - campaign\_action\_url\[action\_url\] (String)

 - campaign\_action\_url\[short\_url\] (String)

 - campaign\_action\_url\[action\_url\_identifier\] (String)



#### PATCH /v1/campaigns/:id/lock\_budget

 lock budget, make budget_editable to false

**Parameters:** 


 - campaign\_id (Integer) (*required*)



#### PATCH /v1/campaigns/:id/pay\_by\_balance

 pay campaign use balance

**Parameters:** 


 - campaign\_id (Integer) (*required*)

 - pay\_way (String) (*required*)



#### POST /v1/campaigns/:id/pay\_by\_alipay

 pay campaign use alipay

**Parameters:** 


 - campaign\_id (Integer) (*required*)



#### PATCH /v1/campaigns/:id/revoke\_campaign

 revoke campaign

**Parameters:** 


 - campaign\_id (Integer) (*required*)



#### PUT /v1/campaigns/:id

 Update a campaign

**Parameters:** 


 - name (String) (*required*)

 - description (String) (*required*)

 - url (String) (*required*)

 - img\_url (String) (*required*)

 - budget (Float) (*required*)

 - per\_budget\_type (String) (*required*)

 - per\_action\_budget (Float) (*required*)

 - message (String)

 - start\_time (DateTime) (*required*)

 - deadline (DateTime) (*required*)

 - sub\_type (String) (*required*)

 - target (Hash) (*required*)

 - target\[age\] (String) (*required*)

 - target\[region\] (String) (*required*)

 - target\[gender\] (String) (*required*)

 - target\[tags\] (String) (*required*)

 - campaign\_action\_url (Hash)

 - campaign\_action\_url\[action\_url\] (String)

 - campaign\_action\_url\[short\_url\] (String)

 - campaign\_action\_url\[action\_url\_identifier\] (String)



#### PUT /v1/campaigns/:id/edit\_base

 Update a campaign base info

**Parameters:** 


 - name (String) (*required*)

 - description (String) (*required*)

 - url (String) (*required*)

 - img\_url (String) (*required*)



#### PUT /v1/campaigns/:id/evaluate

 evaluate  campaign  info

**Parameters:** 


 - review\_content (String) (*required*)

 - effect\_score (Integer) (*required*)



#### POST /v1/recruit\_campaigns

 Create a recruit campaign

**Parameters:** 


 - name (String) (*required*)

 - description (String) (*required*)

 - img\_url (String) (*required*)

 - recruit\_start\_time (DateTime) (*required*)

 - recruit\_end\_time (DateTime) (*required*)

 - start\_time (DateTime) (*required*)

 - deadline (DateTime) (*required*)

 - per\_action\_budget (Float) (*required*)

 - recruit\_person\_count (Float) (*required*)

 - budget (Float)

 - age (String)

 - gender (String)

 - region (String)

 - sns\_platforms (String)

 - tags (String)

 - hide\_brand\_name (Virtus::Attribute::Boolean)

 - material\_ids (String)

 - url (String)

 - sub\_type (String)



#### PUT /v1/recruit\_campaigns/:id

 Update a recruit campaign

**Parameters:** 


 - name (String) (*required*)

 - description (String) (*required*)

 - img\_url (String) (*required*)

 - recruit\_start\_time (DateTime) (*required*)

 - recruit\_end\_time (DateTime) (*required*)

 - start\_time (DateTime) (*required*)

 - deadline (DateTime) (*required*)

 - per\_action\_budget (Float) (*required*)

 - recruit\_person\_count (Float) (*required*)

 - budget (Float)

 - age (String)

 - gender (String)

 - region (String)

 - sns\_platforms (String)

 - tags (String)

 - hide\_brand\_name (Virtus::Attribute::Boolean)

 - material\_ids (String)

 - url (String)

 - sub\_type (String)



#### GET /v1/recruit\_campaigns/:id

 Get a recruit_campaign

**Parameters:** 


 - id (Integer) (*required*)



#### PUT /v1/recruit\_campaigns/:id/end\_apply\_check

 change recruit_campaign's 'end_apply_check' status 

**Parameters:** 


 - id (Integer) (*required*)



#### POST /v1/invite\_campaigns

 Create a invite campaign

**Parameters:** 


 - name (String) (*required*)

 - description (String) (*required*)

 - img\_url (String) (*required*)

 - start\_time (DateTime) (*required*)

 - deadline (DateTime) (*required*)

 - social\_accounts (String) (*required*)

 - material\_ids (String)



#### PUT /v1/invite\_campaigns/:id

 Update a invite campaign

**Parameters:** 


 - name (String) (*required*)

 - description (String) (*required*)

 - img\_url (String) (*required*)

 - start\_time (DateTime) (*required*)

 - deadline (DateTime) (*required*)

 - social\_accounts (String) (*required*)

 - material\_ids (String)



#### GET /v1/invite\_campaigns/:id

 Get a invite campaign

**Parameters:** 


 - id (Integer) (*required*)



#### GET /v1/invite\_campaigns/:id/agreed\_invites

 获取特约活动的campaign_invites

**Parameters:** 


 - id (Integer) (*required*)



#### POST /v1/campaigns/alipay\_notify

 



#### GET /v1/campaign\_invites

 

**Parameters:** 


 - page (Integer) : Page offset to fetch. 

 - per\_page (Integer) : Number of results to return per page. 

 - offset (Integer) : Pad a number of results. 



#### PUT /v1/campaign\_invites/update\_score\_and\_opinion

 

**Parameters:** 


 - campaign\_id (Integer) (*required*)

 - kol\_id (Integer) (*required*)

 - score (String) (*required*)

 - opinion (String) (*required*)



#### GET /v1/campaign\_invites/analysis

 

**Parameters:** 


 - campaign\_id (Integer) (*required*)



#### PUT /v1/campaign\_applies/change\_status

 

**Parameters:** 


 - campaign\_id (Integer) (*required*)

 - kol\_id (Integer) (*required*)

 - status (String) (*required*)



#### PUT /v1/campaign\_applies/:id/pass\_all\_kols

 

**Parameters:** 




#### GET /v1/campaign\_applies

 



#### PUT /v1/campaign\_applies/update\_score\_and\_opinion

 

**Parameters:** 


 - campaign\_id (Integer) (*required*)

 - kol\_id (Integer) (*required*)

 - score (String) (*required*)

 - opinion (String) (*required*)



#### GET /v1/campaign\_materials

 

**Parameters:** 


 - page (Integer) : Page offset to fetch. 

 - per\_page (Integer) : Number of results to return per page. 

 - offset (Integer) : Pad a number of results. 



#### POST /v1/campaign\_materials

 

**Parameters:** 


 - url\_type (String) (*required*)

 - url (String) (*required*)



#### POST /v1/alipay\_orders

 Create a alipay order



#### POST /v1/alipay\_orders/alipay\_notify

 



#### GET /v1/transactions

 

**Parameters:** 


 - page (Integer) : Page offset to fetch. 

 - per\_page (Integer) : Number of results to return per page. 

 - offset (Integer) : Pad a number of results. 



#### GET /v1/invoice\_histories

 

**Parameters:** 


 - page (Integer) : Page offset to fetch. 

 - per\_page (Integer) : Number of results to return per page. 

 - offset (Integer) : Pad a number of results. 



#### GET /v1/invoice\_histories/appliable\_credits

 可申请发票的总额



#### POST /v1/invoice\_histories

 

**Parameters:** 


 - page (Integer) : Page offset to fetch. 

 - per\_page (Integer) : Number of results to return per page. 

 - offset (Integer) : Pad a number of results. 

 - credits (String) (*required*)

 - type (String) (*required*)



#### GET /v1/kols/search

 Search kols with conditions and return kols list

**Parameters:** 


 - region (String)



#### GET /v1/social\_accounts/search

 Search social accounts with conditions and return accounts list

**Parameters:** 


 - region (String)

 - tag (String)

 - sns (String)

 - price\_range (String)



#### GET /v1/social\_accounts/:id

 Get social account full data by id

**Parameters:** 


 - id (Integer) (*required*)



#### GET /v1/invoices/common

 



#### POST /v1/invoices/common

 

**Parameters:** 


 - title (String) (*required*)



#### PUT /v1/invoices/common

 

**Parameters:** 


 - title (String) (*required*)



#### GET /v1/invoices/special

 



#### POST /v1/invoices/special

 

**Parameters:** 


 - title (String) (*required*)

 - invoice\_type (String)

 - taxpayer\_id (String) (*required*)

 - company\_address (String) (*required*)

 - company\_mobile (String) (*required*)

 - bank\_name (String) (*required*)

 - bank\_account (String) (*required*)



#### PUT /v1/invoices/special

 

**Parameters:** 


 - title (String) (*required*)

 - invoice\_type (String)

 - taxpayer\_id (String) (*required*)

 - company\_address (String) (*required*)

 - company\_mobile (String) (*required*)

 - bank\_name (String) (*required*)

 - bank\_account (String) (*required*)




