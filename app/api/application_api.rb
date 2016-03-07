class ApplicationAPI < Grape::API
  format :json

  mount Brand::V1::Endpoints
end
