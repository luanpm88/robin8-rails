module Crm
  class CasesController < Crm::ApplicationController
    before_action :authenticate!

    def index
      @cases = Case.paginate(:page => params[:page])
      render json: { cases: @cases, error: 0 }
    end

    def show
      @case = Case.find_by(id: params[:id])
      render json: { case: @case }
    end
  end
end
