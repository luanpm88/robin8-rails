require 'rails_helper'

describe ReleasesController do
  describe 'POST #create' do
    context 'with valid attributes' do
      it 'creates the release' do
        # post :create, release: attributes_for(:release), format: :json
        # post :create, release: attributes_for(:release), format: :json
        
        # Release.create(attributes_for(:release))
        # expect(Release.count).to eq(1)
      end
    end

    context 'with invalid attributes' do
      it 'does not create the release' do
        post :create, release: attributes_for(:release, title: nil), format: :json
        expect(Release.count).to eq(0)
      end
    end
  end
end
