module Brand
  module V2
    class Base < Grape::API
      desc 'Get supported profession list'
      get '/tags' do
        tags = Tag.where(enabled: true).order("position asc")
        present tags
      end
    end
  end
end