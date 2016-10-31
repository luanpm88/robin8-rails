# encoding: utf-8

#Dir["#{Rails.root}/lib/api/*.rb"].each {|file| require file}

module API
  class Application < Grape::API
    include Grape::PresentCache

    rescue_from ActiveRecord::RecordNotFound do
      rack_response({'message' => '404 Not found'}.to_json, 404)
    end

    logger Logger.new(Rails.root.join("log/grape.log"))

    rescue_from :all do |exception|

      message = "\n #{exception.class} (#{exception.message}): \n"
      message << exception.annoted_source_code.to_s if exception.respond_to?(:annoted_source_code)

      if Rails.env.development? or Rails.env.test?
        puts message
      else
        logger.info message
        Airbrake.notify(exception)
      end
      rack_response({'message' => exception.message}, 500)
    end

    before do
      params.permit! if params
      @log_start_t = Time.now
      # logger.info "Started #{request.request_method} Path #{request.path} IP #{request.ip} ====Authorization:#{headers['Authorization']} === decode:#{AuthToken.decode_data(headers['Authorization'])} "
      logger.info "Started #{request.request_method} Path #{request.path} IP #{request.ip}  "
      logger.info "  Parameters: #{params.to_hash.except("route_info", :password, :password_confirmation)}"
      current_kol.update_tracked_fields request      if current_kol
      ActiveRecord::LogSubscriber.reset_runtime
    end

    after do
      @log_end_t = Time.now
      total_runtime = ((@log_end_t - @log_start_t) * 1000).round(1)
      db_runtime = (ActiveRecord::RuntimeRegistry.sql_runtime || 0).round(1)
      logger.info "Completed in #{total_runtime}ms (ActiveRecord: #{db_runtime}ms)"
    end

    format :json
    helpers API::ApiHelpers
    mount API::V1::AppBase
    mount API::V2::AppBase
    mount API::V1_3::AppBase
    mount API::V1_4::AppBase
    mount API::V1_5::AppBase
    mount API::V1_6::AppBase
    mount API::V1_7::AppBase
    mount API::V1_8::AppBase
    mount API::SearchEngine::AppBase
  end
end
