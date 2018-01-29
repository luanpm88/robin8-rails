### Application



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



#### POST /v1/kols/sign\_in

 



#### POST /v1/kols/oauth\_login

 

**Parameters:** 


 - app\_platform (*required*)

 - app\_version (String) (*required*)

 - device\_token (String) (*required*)

 - city\_name (String)

 - IDFA (String)

 - IMEI (String)

 - provider (String) (*required*)

 - uid (String) (*required*)

 - token (String) (*required*)

 - name (String)

 - url (String)

 - avatar\_url (String)

 - desc (String)

 - serial\_params (JSON)

 - utm\_source (String)



#### POST /v1/phones/verify\_code

 



#### GET /v1/phones/verification\_code

 



#### GET /v1/phones/get\_code

 



#### POST /v1/phones/get\_code

 



#### POST /v1/phones/verification\_code

 



#### GET /v1/tags/list

 



#### GET /v1/campaigns/:id

 

**Parameters:** 


 - id (Integer) (*required*)

 - invitee\_page (Integer)



#### GET /v1/campaigns/:id/invitees

 

**Parameters:** 


 - id (Integer) (*required*)

 - invitee\_page (Integer)



#### PUT /v1/campaigns/:id/approve

 

**Parameters:** 


 - id (Integer) (*required*)



#### PUT /v1/campaigns/:id/receive

 

**Parameters:** 


 - id (Integer) (*required*)



#### PUT /v1/campaigns/can\_apply

 

**Parameters:** 


 - id (Integer) (*required*)



#### PUT /v1/campaigns/apply

 

**Parameters:** 


 - id (Integer) (*required*)

 - name (String)

 - phone (String)

 - weixin\_no (String)

 - weixin\_friend\_count

 - expect\_price (String)

 - remark (String)

 - image\_ids (String)



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



#### GET /v1/cities

 



#### GET /v1/withdraws

 

**Parameters:** 


 - status (String)

 - page (Integer)



#### POST /v1/withdraws/apply

 

**Parameters:** 


 - credits (Float) (*required*)

 - real\_name (String) (*required*)

 - alipay\_no (String) (*required*)

 - remark (String)



#### GET /v1/messages

 

**Parameters:** 


 - status (String)

 - page (Integer)

 - with\_message\_stat (String)



#### PUT /v1/messages/:id/read

 

**Parameters:** 


 - id (Integer) (*required*)



#### POST /v1/feedbacks/create

 

**Parameters:** 


 - app\_version (String) (*required*)

 - app\_platform (String) (*required*)

 - os\_version (String) (*required*)

 - device\_model (String) (*required*)

 - content (String) (*required*)

 - screenshot



#### GET /v1/upgrades/check

 

**Parameters:** 


 - app\_platform (String) (*required*)

 - app\_version (String) (*required*)



#### GET /v1/configs/identify\_enabled

 



#### GET /v2/phones/get\_voice\_code

 



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



#### GET /v2/articles

 

**Parameters:** 


 - type (String)

 - title (String)



#### GET /v2/articles/search

 

**Parameters:** 


 - title (String) (*required*)

 - page (Integer)



#### PUT /v2/articles/action

 

**Parameters:** 


 - article\_id (String) (*required*)

 - article\_title (String) (*required*)

 - article\_url (String) (*required*)

 - article\_avatar\_url (String) (*required*)

 - article\_author (String) (*required*)

 - action (String) (*required*)



#### PUT /v2/article\_actions/:id/action

 

**Parameters:** 


 - id (Integer) (*required*)

 - action (String) (*required*)



#### GET /v2/article\_actions/collect

 

**Parameters:** 


 - page (Integer)



#### GET /v2/article\_actions/forward

 

**Parameters:** 


 - page (Integer)



#### GET /v2/article\_actions/history

 

**Parameters:** 


 - page (Integer)



#### POST /v2/kols/sign\_in

 



#### POST /v2/kols/oauth\_login

 

**Parameters:** 


 - app\_platform (String) (*required*)

 - app\_version (String) (*required*)

 - device\_token (String) (*required*)

 - os\_version (String)

 - device\_model (String)

 - city\_name (String)

 - IDFA (String)

 - IMEI (String)

 - provider (String) (*required*)

 - uid (String) (*required*)

 - token (String) (*required*)

 - name (String)

 - url (String)

 - avatar\_url (String)

 - desc (String)

 - serial\_params (String)

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

 - kol\_uuid (String)

 - utm\_source (String)



#### GET /v2/upgrades/check

 

**Parameters:** 


 - app\_platform (String) (*required*)

 - app\_version (String) (*required*)



#### GET /v2/notify/clean\_cache

 



#### PUT /v2/messages/read\_all

 



#### GET /v2/system/account\_notice

 



#### POST /v1\_3/public\_login/login\_with\_account

 

**Parameters:** 


 - username (String)

 - password (String)

 - imgcode (String)

 - cookies (String)

 - identity\_id (Integer)



#### GET /v1\_3/public\_login/check\_status

 

**Parameters:** 


 - login\_id (Integer) (*required*)



#### GET /v1\_3/my/show

 



#### GET /v1\_3/my/lottery\_activities

 get current kols lottery activities

**Parameters:** 


 - status (String)

 - page (Integer)



#### GET /v1\_3/my/lottery\_activities/:code

 show current kols (:code) lottery activity

**Parameters:** 


 - status (String)



#### GET /v1\_3/my/address

 show current kols address



#### PUT /v1\_3/my/address

 show current kols address

**Parameters:** 


 - name (String)

 - phone (String)

 - region (String)

 - location (String)



#### PUT /v1\_3/tasks/check\_in

 



#### PUT /v1\_3/tasks/complete\_info

 



#### GET /v1\_3/tasks/check\_in\_history

 



#### GET /v1\_3/tasks/invite\_info

 



#### PUT /v1\_3/kols/update\_profile

 

**Parameters:** 


 - app\_platform (String) (*required*)

 - app\_version (String) (*required*)

 - os\_version (String) (*required*)

 - device\_model (String) (*required*)

 - city\_name (String)

 - IDFA (String)

 - IMEI (String)

 - longitude (Float)

 - latitude (Float)



#### GET /v1\_3/kols/alipay

 



#### PUT /v1\_3/kols/bind\_alipay

 

**Parameters:** 


 - alipay\_account (String) (*required*)

 - alipay\_name (String) (*required*)

 - id\_card (String)



#### GET /v1\_3/transactions

 

**Parameters:** 


 - page (Integer)



#### POST /v1\_3/withdraws/apply

 

**Parameters:** 


 - credits (Float) (*required*)



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



#### GET /v1\_3/weixin\_report/primary

 

**Parameters:** 


 - identity\_id (Integer)

 - login\_id (Integer)



#### GET /v1\_3/weixin\_report/messages

 

**Parameters:** 


 - identity\_id (Integer)

 - login\_id (Integer)

 - {:message=>"login\_id identity\_id 必须存在一个"}



#### GET /v1\_3/weixin\_report/articles

 

**Parameters:** 


 - identity\_id (Integer)

 - login\_id (Integer)

 - {:message=>"login\_id identity\_id 必须存在一个"}



#### GET /v1\_3/weixin\_report/user\_analysises

 

**Parameters:** 


 - identity\_id (Integer)

 - login\_id (Integer)

 - {:message=>"login\_id identity\_id 必须存在一个"}



#### GET /v1\_3/weibo\_report/primary

 

**Parameters:** 


 - identity\_id (Integer) (*required*)



#### GET /v1\_3/weibo\_report/follower\_follow

 

**Parameters:** 


 - identity\_id (Integer) (*required*)

 - duration (Integer) (*required*)



#### GET /v1\_3/weibo\_report/follower\_verified

 

**Parameters:** 


 - identity\_id (Integer) (*required*)



#### GET /v1\_3/weibo\_report/friend\_verified

 

**Parameters:** 


 - identity\_id (Integer) (*required*)

 - duration (Integer) (*required*)



#### GET /v1\_3/weibo\_report/follower\_profile

 

**Parameters:** 


 - identity\_id (Integer) (*required*)



#### GET /v1\_3/weibo\_report/statuses

 

**Parameters:** 


 - identity\_id (Integer) (*required*)



#### GET /v1\_3/kol\_identity\_prices/list

 



#### PUT /v1\_3/kol\_identity\_prices/set\_price

 

**Parameters:** 


 - provider (String) (*required*)

 - name (String)

 - follower\_count (String)

 - belong\_field (String)

 - headline\_price (String)

 - second\_price (String)

 - single\_price (String)



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



#### POST /v1\_3/images/upload

 



#### GET /v1\_3/system/config

 



#### PUT /v1\_3/check\_tasks/check\_in

 



#### GET /v1\_3/check\_tasks/check\_in\_history

 



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



#### GET /v1\_4/kol\_brand

 广告主详情页面



#### GET /v1\_4/kol\_brand/bill

 活动账单



#### POST /v1\_4/kol\_brand/recharge

 充值



#### POST /v1\_4/kol\_brand/notify

 支付宝回调

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



#### POST /v1\_4/cpi\_reg/reg\_notice

 注册通知

**Parameters:** 


 - bundle\_name (String) (*required*)

 - app\_platform (String) (*required*)

 - app\_version (String) (*required*)

 - os\_version (String) (*required*)

 - device\_model (String) (*required*)

 - encryption\_data (String) (*required*)



#### GET /v1\_5/tags/list

 



#### GET /v1\_5/hot\_items

 

**Parameters:** 


 - page (Integer)



#### GET /v1\_5/kols/:id/invitee\_detail

 

**Parameters:** 


 - id (Integer) (*required*)



#### GET /v1\_5/influences

 

**Parameters:** 


 - kol\_uuid (String) (*required*)



#### GET /v1\_5/influences/my\_analysis

 

**Parameters:** 


 - kol\_uuid (String) (*required*)



#### POST /v1\_5/scan\_qr\_code\_and\_login

 二维码扫码登录

**Parameters:** 


 - login\_token (String) (*required*)



#### POST /v1\_6/big\_v\_applies/update\_profile

 提交基本资料

**Parameters:** 


 - name (String)

 - app\_city (String)

 - job\_info (String)

 - tag\_names (String)

 - desc (String)

 - age (String)

 - gender (String)



#### POST /v1\_6/big\_v\_applies/update\_social

 

**Parameters:** 


 - provider\_name (String) (*required*)

 - homepage (String)

 - price (String)

 - username (String)

 - uid (String)

 - repost\_price (String)

 - second\_price (String)

 - followers\_count (String)



#### POST /v1\_6/big\_v\_applies/update\_social\_v2

 提交社交账号资料

**Parameters:** 


 - provider\_name (String) (*required*)

 - homepage (String)

 - price (String) (*required*)

 - username (String)

 - uid (String)

 - repost\_price (String)

 - second\_price (String)

 - followers\_count (String)



#### POST /v1\_6/big\_v\_applies/submit\_apply

 提交申请

**Parameters:** 


 - kol\_shows (String)



#### GET /v1\_6/big\_v

 列表

**Parameters:** 


 - page (Integer)

 - with\_kol\_announcement (String)

 - tag\_name (String)

 - name (String)

 - order (String)



#### GET /v1\_6/big\_v/detail

 详情



#### GET /v1\_6/big\_v/:id/detail

 详情

**Parameters:** 




#### POST /v1\_6/big\_v/:id/follow

 关注kol

**Parameters:** 


 - id (Integer)



#### POST /v1\_6/big\_v/unbind\_social\_account

 

**Parameters:** 


 - provider (String) (*required*)

 - id (Integer) (*required*)

 - kol\_id (Integer) (*required*)



#### GET /v1\_6/my/show

 



#### GET /v1\_6/my/friends

 

**Parameters:** 


 - page (Integer)



#### GET /v1\_6/system/account\_notice

 



#### GET /v1\_6/campaigns/materials

 

**Parameters:** 


 - campaign\_id (Integer)

 - campaign\_invite\_id (Integer)



#### POST /v1\_6/campaign\_invites/:id/reject

 

**Parameters:** 


 - id (Integer) (*required*)



#### GET /v1\_6/kol\_filter/kol\_count

 return kol count



#### GET /v1\_7/cps\_articles

 

**Parameters:** 


 - page (Integer)



#### GET /v1\_7/cps\_articles/my\_articles

 

**Parameters:** 


 - page (Integer)

 - status (String) (*required*)



#### POST /v1\_7/cps\_articles/create

 

**Parameters:** 


 - id (Integer)

 - title (String) (*required*)

 - content (String) (*required*)

 - cover (String) (*required*)



#### GET /v1\_7/cps\_articles/:id/show

 

**Parameters:** 




#### GET /v1\_7/cps\_articles/:id/materials

 

**Parameters:** 




#### POST /v1\_7/cps\_articles/share\_article

 

**Parameters:** 


 - cps\_article\_id (Integer)



#### GET /v1\_7/cps\_materials/categories

 



#### GET /v1\_7/cps\_materials

 

**Parameters:** 


 - goods\_name (String)

 - category\_name (String)

 - order\_by (String)

 - page (Integer)



#### POST /v1\_7/images/upload

 

**Parameters:** 


 - file (Hash) (*required*)



#### GET /v1\_8/campaign\_analysis/expect\_effect\_list

 获取活动期望效果列表



#### POST /v1\_8/campaign\_analysis/content\_analysis

 活动分析

**Parameters:** 


 - url (String) (*required*)

 - expect\_effect (String) (*required*)



#### GET /v1\_8/campaign\_analysis/invitee\_analysis

 参与人员分析

**Parameters:** 


 - campaign\_id (Integer) (*required*)



#### POST /v1\_8/campaign\_evaluations/evaluate

 评价活动

**Parameters:** 


 - campaign\_id (Integer) (*required*)

 - effect\_score (Integer) (*required*)

 - experience\_score (Integer)

 - review\_content (String) (*required*)



#### GET /v2\_0/kols/overview

 



#### POST /v2\_0/kols/calculate\_influence\_score

 

**Parameters:** 


 - provider (String) (*required*)



#### GET /v2\_0/kols/influence\_score

 



#### GET /v2\_0/kols/:kol\_id/similar\_kol\_details

 

**Parameters:** 


 - kol\_id (Integer) (*required*)



#### POST /v2\_0/kols/invite\_code

 

**Parameters:** 


 - invite\_code (Integer) (*required*)



#### GET /v2\_0/kols/manage\_influence\_visibility

 

**Parameters:** 


 - action (String) (*required*)



#### POST /v2\_0/contacts/kol\_contacts

 

**Parameters:** 


 - contacts (String) (*required*)



#### POST /v2\_0/contacts/send\_invitation

 

**Parameters:** 


 - mobile\_number (String) (*required*)



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



#### POST /v2\_0/sessions

 v2_0 login

**Parameters:** 


 - login (String) (*required*)

 - password (String) (*required*)



#### GET /search\_engine/kols/list

 

**Parameters:** 


 - tag\_label (String)

 - provider (String)



#### GET /search\_engine/kols/:kol\_id/detail

 

**Parameters:** 


 - kol\_id (String) (*required*)



#### POST /search\_engine/kols/update\_price

 

**Parameters:** 


 - social\_account\_id (Integer) (*required*)

 - price (Float) (*required*)

 - second\_price (Float)

 - repost\_price (Float)




