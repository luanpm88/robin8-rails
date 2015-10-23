class GeocodeController < ApplicationController

  def get_country
    if request.location
      render json: request.location.country.to_json
    end
  end

end
