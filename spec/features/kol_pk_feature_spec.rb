require 'rails_helper'

describe 'Kol PK feature' do
  let!(:kol)      { create(:kol) }
  let!(:identity) { create(:identity, kol_id: kol.id, provider: 'weibo', uid: 'weibo_boss')}

  it 'should allow anyone to login with weibo and start a kol_pk' do
    visit "/kol/#{kol.id}/kol_pk"

    File.open("public/test.html",'w') {|f| f.write(page.body)}

    expect(page).to have_css "a[href^='/auth/weibo']"

    visit "/kol_pk/new/vs/#{kol.id}"
  end
end
