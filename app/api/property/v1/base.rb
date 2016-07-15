require 'doorkeeper/grape/helpers'

module Property
  module V1
    class Base < Grape::API
      before do
        header['Access-Control-Allow-Origin'] = '*'
        header['Access-Control-Request-Method'] = '*'
      end
    end
  end
end
