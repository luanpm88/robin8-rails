require 'rails_helper'

RSpec.describe CampaignWorker do
  it { is_expected.to be_retryable 3 }
end
