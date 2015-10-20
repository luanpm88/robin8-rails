require 'rails_helper'

RSpec.describe IntegrationWithDataEngineWorker do
  it { is_expected.to be_retryable 3 }
end
