### PropertyAPI



#### GET /v1/profile

 



#### PUT /v1/profile

 

**Parameters:** 


 - name (String)

 - email (String)

 - phone (String)

 - avatar\_url (String)



#### GET /v1/account

 



#### DELETE /v1/identity/unbind

 

**Parameters:** 


 - id (Integer) (*required*)



#### GET /v1/wechat/auth\_token

 

**Parameters:** 


 - api\_token (String) (*required*)



#### GET /v1/provinces

 



#### GET /v1/provinces/cities

 

**Parameters:** 


 - province\_id (Integer) (*required*)



#### GET /v1/talking\_data/login

 

**Parameters:** 


 - talkingdata\_promotion\_name (String) (*required*)

 - idfa (String)

 - imei (String)



#### POST /v1/influence\_metric/save\_influence

 

**Parameters:** 


 - api\_token (String) (*required*)

 - provider (String) (*required*)

 - provider\_uid (*required*)

 - influence\_score (*required*)

 - avg\_posts (*required*)

 - avg\_comments (*required*)

 - avg\_likes (*required*)

 - industries (*required*)



####  /*path

 

**Parameters:** 





