### Kols



#### POST /v1/kols/upload\_avatar

 



#### GET /v1/kols/account

 



#### GET /v1/kols/primary

 



#### GET /v1/kols/profile

 



#### PUT /v1/kols/update\_profile

 

**Parameters:** 


 - gender (Integer)



#### PUT /v1/kols/update\_mobile

 

**Parameters:** 


 - mobile\_number (Integer) (*required*)

 - code (Integer) (*required*)



#### PUT /v1/kols/bind\_mobile

 

**Parameters:** 


 - mobile\_number (Integer) (*required*)

 - code (Integer) (*required*)



#### GET /v1/kols/identities

 



#### PUT /v1/kols/bind\_count

 

**Parameters:** 


 - kol\_id (String) (*required*)

 - provider (String) (*required*)



#### PUT /v1/kols/unbind\_count

 

**Parameters:** 


 - kol\_id (String) (*required*)

 - provider (String) (*required*)



#### POST /v1/kols/identity\_bind

 

**Parameters:** 


 - provider (String) (*required*)

 - uid (String) (*required*)

 - token (String) (*required*)

 - name (String)

 - url (String)

 - avatar\_url (String)

 - desc (String)

 - serial\_params (String)

 - followers\_count

 - Integer

 - statuses\_count

 - registered\_at

 - DateTime

 - verified

 - boolean

 - refresh\_token

 - string

 - unionid (String)

 - province (String)

 - city (String)

 - gender (String)

 - is\_vip (Virtus::Attribute::Boolean)

 - is\_yellow\_vip (Virtus::Attribute::Boolean)

 - bind\_type (String)



#### POST /v1/kols/identity\_bind\_v2

 

**Parameters:** 


 - provider (String) (*required*)

 - uid (String) (*required*)

 - token (String) (*required*)

 - name (String)

 - url (String)

 - avatar\_url (String)

 - desc (String)

 - serial\_params (String)

 - followers\_count

 - Integer

 - statuses\_count

 - registered\_at

 - DateTime

 - verified

 - boolean

 - refresh\_token

 - string

 - unionid (String)

 - province (String)

 - city (String)

 - gender (String)

 - is\_vip (Virtus::Attribute::Boolean)

 - is\_yellow\_vip (Virtus::Attribute::Boolean)

 - bind\_type (String)



#### PUT /v1/kols/identity\_unbind

 

**Parameters:** 


 - uid (String) (*required*)



#### PUT /v1/kols/set\_city

 

**Parameters:** 


 - city\_name (String) (*required*)



#### GET /v1/kols/common

 

**Parameters:** 


 - kol\_id (Integer) (*required*)




