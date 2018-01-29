### AnalysisIdentities



#### GET /v1\_3/analysis\_identities/list

 



#### PUT /v1\_3/analysis\_identities/identity\_bind

 

**Parameters:** 


 - provider (String) (*required*)

 - uid (String) (*required*)

 - name (String) (*required*)

 - avatar\_url (String) (*required*)

 - access\_token (String) (*required*)

 - refresh\_token (String) (*required*)

 - location (String) (*required*)

 - gender (String) (*required*)

 - serial\_params (String) (*required*)

 - bind\_type (String) (*required*)



#### PUT /v1\_3/analysis\_identities/identity\_unbind

 

**Parameters:** 


 - identity\_id (String)

 - login\_id (Integer)



#### GET /v1\_3/analysis\_identities/check\_authorize

 

**Parameters:** 


 - id (Integer) (*required*)




