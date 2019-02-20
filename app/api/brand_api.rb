class BrandAPI < Grape::API
  format :json

  # rescue_from CanCan::AccessDenied do |e|
  #   error_response({error: 'Unprocessable!', detail: detail status: 403 })
  # end

  mount Brand::V1::Endpoints
  mount Brand::V2::Endpoints
end
