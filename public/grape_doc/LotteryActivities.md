### LotteryActivities



#### GET /v1\_3/lottery\_activities

 get all avaliable lottery activities.

**Parameters:** 


 - page (Integer)



#### GET /v1\_3/lottery\_activities/:code

 show (:code) lottery activity.

**Parameters:** 


 - code (String) (*required*)



#### GET /v1\_3/lottery\_activities/:code/desc

 show description of (:code) lottery activity.

**Parameters:** 


 - code (String) (*required*)



#### GET /v1\_3/lottery\_activities/:code/orders

 get order list if (:code) lottery activity.

**Parameters:** 


 - code (String) (*required*)

 - page (Integer)



#### GET /v1\_3/lottery\_activities/:code/formula

 show drawing formula of (:code) lottery activity.

**Parameters:** 


 - code (String) (*required*)



#### POST /v1\_3/lottery\_orders

 create an order

**Parameters:** 


 - activity\_code (String) (*required*)

 - num (Integer) (*required*)



#### PUT /v1\_3/lottery\_orders/:code/checkout

 checkout lottery activity order and pay

**Parameters:** 


 - code (String) (*required*)




