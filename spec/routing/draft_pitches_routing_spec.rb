require "rails_helper"

RSpec.describe DraftPitchesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/draft_pitches").to route_to("draft_pitches#index")
    end

    it "routes to #new" do
      expect(:get => "/draft_pitches/new").to route_to("draft_pitches#new")
    end

    it "routes to #show" do
      expect(:get => "/draft_pitches/1").to route_to("draft_pitches#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/draft_pitches/1/edit").to route_to("draft_pitches#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/draft_pitches").to route_to("draft_pitches#create")
    end

    it "routes to #update" do
      expect(:put => "/draft_pitches/1").to route_to("draft_pitches#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/draft_pitches/1").to route_to("draft_pitches#destroy", :id => "1")
    end

  end
end
