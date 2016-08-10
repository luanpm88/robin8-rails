import mirrorCreator from 'mirror-creator';

const actionTypes = mirrorCreator([
  'FETCH_CAMPAIGNS', 'SAVE_CAMPAIGN',
  'FETCH_CAMPAIGN', 'UPDATE_CAMPAIGN', 'FETCH_INVITES_OF_CAMPAIGN',
  'FETCH_RECRUIT_CAMPAIGN', 'FETCH_APPLIES_OF_RECRUIT_CAMPAIGN', 'UPDATE_RECRUIT_CAMPAIGN_KOL_STATUS', 'UPDATE_RECRUIT_CAMPAIGN_KOLS',
  'FETCH_STATISTICS_CLICKS_OF_CAMPAIGN', "FETCH_INSTALLS_OF_CAMPAIGN",
  'FETCH_BRAND_PROFILE', 'UPDATE_BRAND_PROFILE',
  'UPDATE_BRAND_PASSWORD',
  "FETCH_RECRUIT", "UPDATE_RECRUIT",
  "FETCH_RECRUIT_CAMPAIGN_MATERIALS",
  "ALIPAY_RECHARGE",
  "FETCH_TRANSACTIONS",
  "FETCH_INVOICE", "SAVE_INVOICE", 'UPDATE_INVOICE',
  "FETCH_INVOICE_RECEIVER", 'SAVE_INVOICE_RECEIVER', 'UPDATE_INVOICE_RECEIVER',
  "FETCH_APPLIABLE_CREDITS",
  "FETCH_INVOICE_HISTORIES", "SAVE_INVOICE_HISTORY",
  "GO_PAY_CAMPAIGN", "PAY_CAMPAIGN_BY_BALANCE", "PAY_CAMPAIGN_BY_ALIPAY", "REVOKE_CAMPAIGN",
  "FETCH_INVITE_CAMPAIGN", "UPDATE_INVITE_CAMPAIGN", 'FETCH_AGREED_INVITES_OF_INVITE_CAMPAIGN',
  "UPDATE_KOL_SCORE_AND_BRAND_OPINION",
  "SEARCH_KOLS_IN_CONDITION",
  "ADD_SELECTED_KOL", "REMOVE_SELECTED_KOL"
]);

export default actionTypes;
