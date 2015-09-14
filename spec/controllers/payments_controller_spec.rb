require 'rails_helper'

describe PaymentsController do
  let!(:user) { stub_model(User, email: 'test@test.com', id: 1) }
  let!(:params) { {} }
  let!(:product) { create(:product, id: 1, slug: "basic-monthly", is_active: true, price: 19.00, interval: 30, name: "Basic Monthly", description: "basic monthly subscription", sku_id:3262130,is_package: true) }

  before do
    allow(controller).to receive(:current_user).and_return user
    allow(controller).to receive(:authenticate_user!).and_return true
    BlueSnap::Shopper.stub(:new).and_return(bluesnap_array)
    
    allow(controller).to receive(:require_package).and_return true
    controller.instance_variable_set(:@product, product)
  end

  describe "#create" do
    subject { post :create, params }

    it "should create the post" do
      params.merge!({"payment_option"=>"basic-monthly", "code"=>"", "slug"=>"basic-monthly", "contact"=>{"title"=>"Mr", "first_name"=>"dfg", "last_name"=>"dfg", "phone"=>"1234567890", "address1"=>"Lviv", "city"=>"Lviv", "state"=>"NY", "zip"=>"12345", "country"=>"US"}, "card"=>{"credit_card_type"=>"visa", "expiration_month"=>"05", "expiration_year"=>"2019"}})
      subject
      expect(user.user_products.first).not_to be_nil
    end
  end
end