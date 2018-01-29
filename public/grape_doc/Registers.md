### Registers



#### GET /v2\_0/registers/valid\_code

 get valid code by your email.

**Parameters:** 


 - email (String) (*required*)



#### POST /v2\_0/registers/valid\_email

 email valid code

**Parameters:** 


 - email (String) (*required*)

 - valid\_code (String) (*required*)



#### POST /v2\_0/registers

 create new kol

**Parameters:** 


 - name (String) (*required*)

 - email (String) (*required*)

 - password (String) (*required*)

 - vtoken (String) (*required*) : 邮箱验证成功生成的token 

 - mobile\_number (String)




