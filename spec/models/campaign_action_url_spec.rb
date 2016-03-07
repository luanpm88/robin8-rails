require 'rails_helper'

RSpec.describe CampaignActionUrl, :type => :model do
  it { is_expected.to validate_presence_of(:action_url) }
  it { is_expected.to validate_presence_of(:campaign_id) }
end
