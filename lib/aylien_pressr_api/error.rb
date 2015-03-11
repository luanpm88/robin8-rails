# Copyright 2015 Aylien, Inc. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

module AylienPressrApi
  class Error < StandardError
    # Raised when Aylien Pressr API returns a 4xx HTTP status code
    ClientError = Class.new(self)

    # Raised when Aylien Pressr API returns the HTTP status code 400
    BadRequest = Class.new(ClientError)

    # Raised when Aylien Pressr API returns the HTTP status code 401
    Unauthorized = Class.new(ClientError)

    # Raised when Aylien Pressr API returns the HTTP status code 402
    PaymentRequired = Class.new(ClientError)

    # Raised when Aylien Pressr API returns the HTTP status code 403
    Forbidden = Class.new(ClientError)

    # Raised when Aylien Pressr API returns the HTTP status code 404
    NotFound = Class.new(ClientError)

    # Raised when Aylien Pressr API returns the HTTP status code 406
    NotAcceptable = Class.new(ClientError)

    # Raised when Aylien Pressr API returns the HTTP status code 422
    UnprocessableEntity = Class.new(ClientError)

    # Raised when Aylien Pressr API returns the HTTP status code 429
    TooManyRequests = Class.new(ClientError)

    # Raised when Aylien Pressr API returns a 5xx HTTP status code
    ServerError = Class.new(self)

    # Raised when Aylien Pressr API returns the HTTP status code 500
    InternalServerError = Class.new(ServerError)

    # Raised when Aylien Pressr API returns the HTTP status code 502
    BadGateway = Class.new(ServerError)

    # Raised when Aylien Pressr API returns the HTTP status code 503
    ServiceUnavailable = Class.new(ServerError)

    # Raised when Aylien Pressr API returns the HTTP status code 504
    GatewayTimeout = Class.new(ServerError)

    ERRORS = {
      400 => AylienPressrApi::Error::BadRequest,
      401 => AylienPressrApi::Error::Unauthorized,
      402 => AylienPressrApi::Error::PaymentRequired,
      403 => AylienPressrApi::Error::Forbidden,
      404 => AylienPressrApi::Error::NotFound,
      406 => AylienPressrApi::Error::NotAcceptable,
      422 => AylienPressrApi::Error::UnprocessableEntity,
      429 => AylienPressrApi::Error::TooManyRequests,
      500 => AylienPressrApi::Error::InternalServerError,
      502 => AylienPressrApi::Error::BadGateway,
      503 => AylienPressrApi::Error::ServiceUnavailable,
      504 => AylienPressrApi::Error::GatewayTimeout,
    }

    class << self
      # Create a new error from an HTTP response
      #
      # @param response [HTTP::Response]
      # @return [AylienPressrApi::Error]
      def from_response(response)
        body = if response["Content-Type"].include?('json')
          JSON.parse(response.body, :symbolize_names => true)
        else
          response.body
        end
        message = parse_error(body)
        new(message)
      end

    private

      def parse_error(body)
        if body.nil? || body.empty?
          ''
        elsif body.is_a?(Hash) && body[:error]
          body[:error]
        else
          body
        end
      end
    end

    # Initializes a new Error object
    #
    # @param message [Exception, String]
    # @return [AylienPressrApi::Error]
    def initialize(message = '')
      super(message)
    end
  end
end
