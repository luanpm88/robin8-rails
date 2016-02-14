class HelloWorldController < ApplicationController
  layout false
  def index
    @hello_world_props = { name: "Stranger" }
  end
end
