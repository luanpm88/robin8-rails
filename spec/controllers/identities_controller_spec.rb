require 'rails_helper'

RSpec.describe IdentitiesController, type: :controller do

  describe "GET #current_categories" do
    it "returns http success" do
      get :current_categories
      expect(response).to have_http_status(:success)
    end
  end

end
