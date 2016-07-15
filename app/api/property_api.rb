class PropertyAPI < Grape::API
  include Grape::PresentCache

  format :json

  mount Property::V1::Root

  rescue_from ActiveRecord::RecordNotFound do
    error!({ error: 'Record can not be found' }, 404)
  end

  # rescue_from :all do |exception|
  #   error!({ error: 'server error' }, 500)
  # end

  route :any, '*path' do
    error!({ error: 'Route can not be found' }, 404)
  end
end
