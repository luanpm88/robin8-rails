# encoding: utf-8
module API
  module V2_0
    class Tasks < Grape::API
    	resources :tasks do
        before do
          authenticate!
        end

        
      end
    end
  end
end