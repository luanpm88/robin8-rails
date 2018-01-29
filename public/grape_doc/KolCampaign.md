### KolCampaign



#### POST /v1\_4/kol\_campaigns

 Create a campaign

**Parameters:** 


 - name (String) (*required*)

 - description (String) (*required*)

 - url (String) (*required*)

 - budget (Float) (*required*)

 - per\_budget\_type (String) (*required*)

 - per\_action\_budget (Float) (*required*)

 - start\_time (DateTime) (*required*)

 - deadline (DateTime) (*required*)

 - sub\_type (String)

 - img (Hash)

 - img\_url (String)

 - age (String)

 - gender (String)

 - region (String)

 - tags (String)



#### PUT /v1\_4/kol\_campaigns/update

 更新campaign

**Parameters:** 


 - id (Integer) (*required*)

 - name (String)

 - description (String)

 - url (String)

 - img (Hash)

 - img\_url (String)

 - per\_budget\_type (String)

 - per\_action\_budget (Float)

 - start\_time (DateTime)

 - deadline (DateTime)

 - budget (Float)

 - sub\_type (String)

 - age (String)

 - gender (String)

 - region (String)

 - tags (String)



#### GET /v1\_4/kol\_campaigns

 campaign list 列表



#### PUT /v1\_4/kol\_campaigns/pay\_by\_voucher

 是否使用 任务奖金 抵用

**Parameters:** 


 - id (Integer) (*required*)

 - used\_voucher (Integer) (*required*)



#### GET /v1\_4/kol\_campaigns/show

 获取详情

**Parameters:** 


 - id (Integer) (*required*)



#### GET /v1\_4/kol\_campaigns/joined\_kols

 获取campaign 参与人的列表

**Parameters:** 


 - id (Integer) (*required*)



#### GET /v1\_4/kol\_campaigns/detail

 获取 全的详情

**Parameters:** 


 - id (Integer) (*required*)



#### PUT /v1\_4/kol\_campaigns/pay

 通过brand 余额 支付

**Parameters:** 


 - id (Integer) (*required*)

 - pay\_way (String) (*required*)



#### POST /v1\_4/kol\_campaigns/notify

 支付宝回调地址

**Parameters:** 


 - out\_trade\_no (String)

 - discount (String)

 - payment\_type (String)

 - subject (String)

 - trade\_no (String)

 - buyer\_email (String)

 - gmt\_create (String)

 - notify\_type (String)

 - quantity (String)

 - seller\_id (String)

 - notify\_time (String)

 - body (String)

 - trade\_status (String)

 - is\_total\_fee\_adjust (String)

 - total\_fee (String)

 - gmt\_payment (String)

 - seller\_email (String)

 - price (String)

 - buyer\_id (String)

 - notify\_id (String)

 - use\_coupon (String)

 - sign\_type (String)

 - sign (String)



#### PUT /v1\_4/kol\_campaigns/revoke

 审核通过前 撤销

**Parameters:** 


 - id (Integer) (*required*)




