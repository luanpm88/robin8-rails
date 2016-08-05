module Brand
  module V1
    class UtilAPI < Base
      
      before do
        # authenticate!
      end

      desc 'Get Qiniu upload token'
      get '/qiniu_token' do
        put_policy = Qiniu::Auth::PutPolicy.new 'robin8'
        uptoken = Qiniu::Auth.generate_uptoken put_policy
        {uptoken: uptoken}
      end

      desc 'Get supported profession list'
      get '/professions' do
        professions = Profession.where(enable: true).order("position asc")
        present professions
      end
    end
  end
end
