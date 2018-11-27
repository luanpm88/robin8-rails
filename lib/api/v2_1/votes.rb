# coding: utf-8
module API
  module V2_1
    class Votes < Grape::API
      resources :kols do
        before do
          authenticate! unless @options[:path].join("").match('sms')

          # if %w(be_kol vote vote_sms).include?(@options[:path].join(""))
          #   return {error: 1, detail: '暂无该活动'} unless $redis.get('vote_switch') == '1'
          #   return {error: 1, detail: '活动未开始'} if Time.now < $redis.get('vote_start_at').to_time
          #   return {error: 1, detail: '活动已结束'} if Time.now > $redis.get('vote_end_at').to_time
          # end
        end

        desc 'my idois list'
        params do
        	requires :page, type: Integer
        end
        get 'my_idois' do
        	my_idois = Kol.joins(:voter_ships).where('voter_ships.voter_id=?', current_kol.id).order(is_hot: :desc)

        	list = paginate(Kaminari.paginate_array(my_idois))

          present :error, 0
          present :list, list, with: API::V2_1::Entities::KolEntities::Brief, mobile_number: current_kol.mobile_number
        end

        desc 'my fans list'
        params do
        	requires :page, type: Integer
        end
        get 'my_voters' do
        	list = paginate(Kaminari.paginate_array(current_kol.voter_ships.includes(:voter)))

          present :error, 0
          present :list, list, with: API::V2_1::Entities::KolEntities::Voter
        end

        desc 'be kol'
        post 'be_kol' do
          return {error: 1, detail: '暂无该活动'} unless $redis.get('vote_switch') == '1'
          return {error: 1, detail: '活动未开始'} if Time.now < $redis.get('vote_start_at').to_time
          return {error: 1, detail: '活动已结束'} if Time.now > $redis.get('vote_end_at').to_time
          
          current_kol.update_columns(is_hot: 0) unless current_kol.is_hot

          present :error, 0
        end

        desc 'vote in app'
        params do
          requires :kol_id,  type: Integer
        end
        post 'vote' do
          return {error: 1, detail: '暂无该活动'} unless $redis.get('vote_switch') == '1'
          return {error: 1, detail: '活动未开始'} if Time.now < $redis.get('vote_start_at').to_time
          return {error: 1, detail: '活动已结束'} if Time.now > $redis.get('vote_end_at').to_time

          return {error: 1, detail: '今天对当前KOL已投过票'} if $redis.get("#{current_kol.mobile_number}_vote_kol_#{params[:kol_id]}")

          _kol = Kol.find_by_id(params[:kol_id])
          
          return {error: 1, detail: '支持的信息有误'} unless _kol.try(:is_hot)

          voter_ship = VoterShip.find_or_initialize_by(kol_id: _kol.id, voter_id: current_kol.id)
          voter_ship.count += 1
          voter_ship.save

          Vote.create(tender_id: current_kol.id, kol_id: _kol.id)

          present :error,        0
          present :count,        _kol.redis_votes_count.value
          present :vote_ranking, _kol.vote_ranking
        end

        desc 'get vote sms valid_code'
        params do
          requires :mobile_number, type: String
          requires :kol_id,        type: Integer
        end
        get 'vote_sms' do
          return {error: 1, detail: '暂无该活动'} unless $redis.get('vote_switch') == '1'
          return {error: 1, detail: '活动未开始'} if Time.now < $redis.get('vote_start_at').to_time
          return {error: 1, detail: '活动已结束'} if Time.now > $redis.get('vote_end_at').to_time

          return {error: 1, detail: '请求频繁，请稍后再试'}  if $redis.get("#{params[:mobile_number]}_vote_kol_#{params[:kol_id]}_sms")
          return {error: 1, detail: '今天对当前KOL已投过票'} if $redis.get("#{params[:mobile_number]}_vote_kol_#{params[:kol_id]}")
          return {error: 1, detail: '手机号格式错误'}       unless params[:mobile_number].match(API::ApiHelpers::MOBILE_NUMBER_REGEXP)
          return {error: 1, detail: '支持的信息有误'}       unless Kol.find_by_id(params[:kol_id]).try(:is_hot)

          YunPian::SendRegisterSms.new(params[:mobile_number]).send_sms

          # 60秒内不能重复发
          $redis.setex("#{params[:mobile_number]}_vote_kol_#{params[:kol_id]}_sms", 120, '1')

          present :error, 0
        end

        desc 'vote by sms valid_code'
        params do
          requires :mobile_number, type: String
          requires :kol_id,        type: Integer
          requires :code,          type: String
        end
        post 'vote_sms' do
          return {error: 1, detail: '暂无该活动'} unless $redis.get('vote_switch') == '1'
          return {error: 1, detail: '活动未开始'} if Time.now < $redis.get('vote_start_at').to_time
          return {error: 1, detail: '活动已结束'} if Time.now > $redis.get('vote_end_at').to_time

          return {error: 1, detail: '今天对当前KOL已投过票'} if $redis.get("#{params[:mobile_number]}_vote_kol_#{params[:kol_id]}")
          
          code_right = YunPian::SendRegisterSms.verify_code(params[:mobile_number], params[:code])

          return {error: 1, detail: '验证码错误'}    unless code_right
          return {error: 1, detail: '支持的信息有误'} unless Kol.find_by_id(params[:kol_id]).try(:is_hot)


          k = Kol.find_or_initialize_by(mobile_number: params[:mobile_number])
          if k.new_record?
            k.name = Kol.hide_real_mobile_number(params[:mobile_number])
            k.save
          end

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
