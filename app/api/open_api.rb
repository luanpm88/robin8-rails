class OpenAPI < Grape::API
  include Grape::PresentCache

  STORE_KEY = "robin8:open:access_tokens"

  logger Logger.new(Rails.root.join("log/open_api.log"))

  format :json

  before do
    params.permit! if params
    @log_start_t = Time.now
    logger.info "#{request.request_method} #{request.path}"
    logger.info "IP: #{request.ip}, Authorization: #{headers['Authorization']}"
    logger.info "Params: #{params.to_hash.except("route_info", :password, :password_confirmation)}"
  end

  after do
    @log_end_t = Time.now
    total_runtime = ((@log_end_t - @log_start_t) * 1000).round(1)
    db_runtime = (ActiveRecord::RuntimeRegistry.sql_runtime || 0).round(1)
    logger.info "Completed in #{total_runtime}ms (ActiveRecord: #{db_runtime}ms)"
  end

  rescue_from Open::UnauthorizationError do |e|
    OpenAPI.logger.error "Error: #{e.inspect}"
    rack_response({ success: false, error: "没有接口调用的权限" }.to_json, 403)
  end

  rescue_from Open::LimitationError do |e|
    OpenAPI.logger.error "Error: #{e.inspect}"
    rack_response({ success: false, error: "超过请求限制" }.to_json, 403)
  end

  rescue_from ActiveRecord::RecordNotFound do |e|
    OpenAPI.logger.error "Error: #{e.inspect}"
    rack_response({ success: false, error: "没有找到相应记录" }.to_json, 404)
  end

  rescue_from Grape::Exceptions::ValidationErrors do |e|
    OpenAPI.logger.error "Error: #{e.inspect}"
    rack_response({ success: false, error: "所提交的参数不正确" }.to_json, 400)
  end

  rescue_from StandardError do |e|
    OpenAPI.logger.error "Error: #{e.inspect}"
    Airbrake.notify(e) unless Rails.env.development? and Rails.env.test?
    rack_response({ success: false, error: e.message }.to_json, 400)
  end

  helpers Open::ApiHelper
  mount   Open::V1::Root

  route :any, '*path' do
    error!({ success: false, error: '没有相应的请求路径' }, 404)
  end
end
