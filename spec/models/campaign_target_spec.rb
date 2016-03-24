require 'rails_helper'

RSpec.describe CampaignTarget, type: :model do
  it { is_expected.to belong_to(:campaign) }
  it { is_expected.to validate_presence_of(:target_type) }
  it { is_expected.to validate_presence_of(:target_content) }
  it { is_expected.to validate_inclusion_of(:target_type).in_array(%w(age region gender)) }
end
