### CampaignInvites



#### GET /v1/campaign\_invites

 

**Parameters:** 


 - status (String) (*required*)

 - page (Integer)

 - title (String)

 - with\_message\_stat (String)

 - with\_announcements (String)



#### GET /v1/campaign\_invites/my\_campaigns

 

**Parameters:** 


 - status (String) (*required*)

 - page (Integer)



#### GET /v1/campaign\_invites/:id

 

**Parameters:** 


 - id (Integer) (*required*)

 - invitee\_page (Integer)



#### PUT /v1/campaign\_invites/:id/approve

 

**Parameters:** 


 - id (Integer) (*required*)



#### PUT /v1/campaign\_invites/:id/upload\_screenshot

 

**Parameters:** 


 - id (Integer) (*required*)



#### PUT /v1/campaign\_invites/:id/share

 

**Parameters:** 


 - id (Integer) (*required*)

 - sub\_type (String)




