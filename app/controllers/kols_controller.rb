class KolsController < ApplicationController

  def get_current_kol
    render json: current_kol
  end

end

