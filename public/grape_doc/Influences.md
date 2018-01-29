### Influences



#### GET /v2/influences/start

 



#### POST /v2/influences/bind\_identity

 

**Parameters:** 


 - provider (String) (*required*)

 - uid (String) (*required*)

 - token (String) (*required*)

 - name (String) (*required*)

 - kol\_uuid (String) (*required*)

 - serial\_params (String)

 - url (String)

 - avatar\_url (String)

 - desc (String)

 - followers\_count (Integer)

 - statuses\_count (Integer)

 - registered\_at (DateTime)

 - verified (Virtus::Attribute::Boolean)

 - refresh\_token (String)

 - unionid (String)

 - province (String)

 - city (String)

 - gender (String)

 - is\_vip (Virtus::Attribute::Boolean)

 - is\_yellow\_vip (Virtus::Attribute::Boolean)



#### POST /v2/influences/unbind\_identity

 

**Parameters:** 


 - provider (String) (*required*)

 - uid (String) (*required*)

 - kol\_uuid (String) (*required*)



#### POST /v2/influences/bind\_contacts

 

**Parameters:** 


 - contacts (String) (*required*)

 - kol\_uuid (String)



#### POST /v2/influences/cal\_score

 

**Parameters:** 


 - kol\_uuid (String) (*required*)

 - kol\_mobile\_model (String) (*required*)

 - kol\_city (String)



#### GET /v2/influences/rank

 

**Parameters:** 


 - kol\_uuid (String) (*required*)



#### GET /v2/influences/rank\_with\_page

 

**Parameters:** 


 - kol\_uuid (String) (*required*)

 - page (Integer) (*required*)



#### GET /v2/influences/item\_detail

 

**Parameters:** 


 - kol\_uuid (String) (*required*)



#### GET /v2/influences/upgrade

 

**Parameters:** 


 - kol\_uuid (String) (*required*)



#### PUT /v2/influences/share

 

**Parameters:** 


 - kol\_uuid (String) (*required*)



#### POST /v2/influences/send\_invite

 

**Parameters:** 


 - kol\_uuid (String) (*required*)

 - mobile (String) (*required*)




