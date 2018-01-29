### OpenAPI



#### GET /v1/kols

 Get KOL(BigV) list

**Parameters:** 


 - page (Integer)

 - tag (String)

 - name (String)

 - order (String)



#### GET /v1/kols/:id/show

 Get Kol(BigV) detail by id

**Parameters:** 




#### GET /v1/kols/search\_count

 获取kol数量



#### POST /v1/campaigns

 create an campaign

**Parameters:** 


 - name (String)

 - description (String)

 - url (String) (*required*)

 - budget (Float) (*required*)

 - per\_action\_budget (Float) (*required*)

 - start\_time (DateTime) (*required*)

 - deadline (DateTime) (*required*)

 - per\_budget\_type (String) (*required*)

 - enable\_append\_push (Virtus::Attribute::Boolean)

 - poster\_url (String) (*required*)

 - screenshot\_url (String)

 - age (String)

 - gender (String)

 - region (String)

 - tags (String)



#### PUT /v1/campaigns/:id

 update existed campaign

**Parameters:** 


 - id (Integer) (*required*)

 - name (String)

 - description (String)

 - url (String)

 - per\_action\_budget (Float)

 - start\_time (DateTime)

 - deadline (DateTime)

 - per\_budget\_type (String)

 - enable\_append\_push (Virtus::Attribute::Boolean)

 - poster\_url (String)

 - screenshot\_url (String)

 - age (String)

 - gender (String)

 - region (String)

 - tags (String)



#### DELETE /v1/campaigns/:id/revoke

 revoke campaign

**Parameters:** 


 - id (Integer) (*required*)



#### DELETE /v1/campaigns/:id/stop

 stop campaign

**Parameters:** 


 - id (Integer) (*required*)



#### GET /v1/campaigns

 get all campaign of current user

**Parameters:** 


 - campaign\_type (String)

 - page (Integer)



#### GET /v1/campaigns/:id

 get campaign detail by id

**Parameters:** 


 - id (Integer) (*required*)



#### GET /v1/campaigns/:id/invites

 get joined kol invites of campaign

**Parameters:** 


 - id (Integer) (*required*)



#### POST /v1/campaigns/click\_stats

 statist campaign click

**Parameters:** 


 - id (Integer) (*required*)

 - starttime (String) (*required*)

 - endtime (String) (*required*)



#### GET /v1/transactions

 get all transactions of current user

**Parameters:** 


 - page (Integer)



####  /*path

 

**Parameters:** 





