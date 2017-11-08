require 'rails_helper'

describe 'Campaign show pages', :type => :feature do

  before do
    allow($weixin_client).to receive(:authorize_url).and_return('http://robin8.net/')
  end

  let!(:campaign_invite) { create(:campaign_invite, id: 123, uuid: 'abc')}
  let!(:campaign_invite_deleted) { create(:campaign_invite, id: 124, uuid: 'cde', deleted: true)}

  it 'should redirect on non-deleted invite' do
    visit '/campaign_visit?id=123'
    expect(page.current_path).to eq '/'
  end

  it 'should redirect on deleted invite' do
    visit '/campaign_visit?id=124'
    expect(page.current_path).to eq '/'
  end
end
