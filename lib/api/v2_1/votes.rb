# coding: utf-8
module API
  module V2_1
    class Votes < Grape::API
      resources :kols do
        before do
          authenticate! unless @options[:path].join("").match('sms')
        end

        desc '我的爱豆列表'
        params do
        	requires :page, type: Integer
        end
        get 'my_idois' do
        	my_idois = Kol.joins(:voter_ships).where('voter_ships.voter_id=?', current_kol.id).order(is_hot: :desc)

        	list = paginate(Kaminari.paginate_array(my_idois))
          present :error, 0
          present :list, list, with: API::V2_1::Entities::KolEntities::Brief
        end

        desc '我的粉丝列表'
        params do
        	requires :page, type: Integer
        end
        get 'my_voters' do
        	list = paginate(Kaminari.paginate_array(current_kol.voter_ships.includes(:voter)))
          present :error, 0
          present :list, list, with: API::V2_1::Entities::KolEntities::Voter
        end

        desc '我要报名，我要当网红'
        post 'be_kol' do
          current_kol.update_columns(is_hot: 0) unless current_kol.is_hot

          present :error, 0
        end

        desc '获取投票验证码'
        params do
          requires :mobile_number, type: String
          requires :kol_id,        type: Integer
        end
        get 'vote_sms' do
          error_403!(detail: '手机号格式错误') unless params[:mobile_number].match(API::ApiHelpers::MOBILE_NUMBER_REGEXP)
          error_403!(detail: '支持的信息有误') unless Kol.find_by_id(params[:kol_id]).try(:is_hot)

          _key = "#{params[:mobile_number]}vote_kol_#{params[:kol_id]}"
          
          error_403!(detail: '24小时内针对一个kol只能投一次票') if $redis.get(_key) == '1'

          YunPian::SendRegisterSms.new(params[:mobile_number]).send_sms

          present :error, 0 
        end

        desc '投票'
        params do
          requires :mobile_number, type: String
          requires :kol_id,        type: Integer
          requires :code,          type: String
        end
        post 'vote_sms' do
          code_right = YunPian::SendRegisterSms.verify_code(params[:mobile_number], params[:code])

          error_403!(detail:  '验证码错误')   unless code_right
          error_403!(detail: '支持的信息有误') unless Kol.find_by_id(params[:kol_id]).try(:is_hot)

          _key = "#{params[:mobile_number]}vote_kol_#{params[:kol_id]}"

          $redis.setex(_key, 24.hours, '1')

          k = Kol.find_or_initialize_by(mobile_number: params[:mobile_number])
          k.save if k.new_record?

          voter_ship = VoterShip.find_or_initialize_by(kol_id: params[:kol_id], voter_id: k.id)
          voter_ship.count += 1
          voter_ship.save

          Vote.create(tender_id: k.id, kol_id: params[:kol_id])

          present :error, 0
        end
			end
		end
	end
end
