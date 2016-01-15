require 'rails_helper'

RSpec.describe DiscoverRecord, type: :model do
  it { is_expected.to validate_presence_of(:kol_id) }
  it { is_expected.to validate_presence_of(:discover_id) }

  it 'clean' do
    FactoryGirl.create(:discover_record)
  end

  it 'test' do
    expect(DiscoverRecord.count).to eq 0
  end
end
