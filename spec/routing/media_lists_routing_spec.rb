require "rails_helper"

RSpec.describe MediaListsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/media_lists").to route_to("media_lists#index")
    end

    it "routes to #new" do
      expect(:get => "/media_lists/new").to route_to("media_lists#new")
    end

    it "routes to #show" do
      expect(:get => "/media_lists/1").to route_to("media_lists#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/media_lists/1/edit").to route_to("media_lists#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/media_lists").to route_to("media_lists#create")
    end

    it "routes to #update" do
      expect(:put => "/media_lists/1").to route_to("media_lists#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/media_lists/1").to route_to("media_lists#destroy", :id => "1")
    end

  end
end
