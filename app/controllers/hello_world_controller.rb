class HelloWorldController < ApplicationController
  layout 'brand'
  def index
    @hello_world_props = { name: "Stranger" }
  end
end
