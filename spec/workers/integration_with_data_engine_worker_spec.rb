require 'rails_helper'

RSpec.describe IntegrationWithDataEngineWorker do
  it { is_expected.to be_retryable 3 }

  it 'logger the job when retries exhausted' do
    IntegrationWithDataEngineWorker.within_sidekiq_retries_exhausted_block {
      expect(Rails.logger).to receive(:warn)
    }
  end
end
