module API
  module V1_3
    module Entities
      module LotteryActivityEntities
        class Kol < Grape::Entity
          expose :id

          expose :name do |kol|
            kol.safe_name
          end

          expose :avatar_url do |kol|
            kol.avatar.url rescue nil
          end
        end

        class Order < Grape::Entity
          expose :id, :code, :number, :created_at, :credits
        end

        class Basic < Grape::Entity
          expose :id, :name, :code, :total_number, :actual_number, :status, :published_at

          expose :name do |activity|
            activity.lottery_product.name
          end

          expose :poster_url do |activity|
            activity.lottery_product.cover.url rescue nil
          end
        end

        class Description < Grape::Entity
          expose :id, :name, :code, :description
        end

        class Ticket < Grape::Entity
          expose :id, :code
        end

        class Address < Grape::Entity
          expose :name, :phone, :region, :location
        end

        class Detail < Basic
          expose :token_number, if: lambda { |activity, opts| opts[:kol] } do |activity, opts|
            activity.token_number options[:kol]
          end

          expose :winner_self, if: lambda { |activity, opts| opts[:kol] } do |activity, opts|
            activity.lucky_kol === options[:kol]
          end

          expose :winner_name do |activity|
            activity.lucky_kol.safe_name rescue nil
          end

          expose :winner_token_number do |activity|
            activity.token_number(activity.lucky_kol) rescue nil
          end
        end

        class Show < Basic
          expose :lucky_number

          expose :draw_at do |activity|
            activity.draw_at.strftime("%Y-%m-%d %H:%M:%S") rescue nil
          end

          expose :description do |activity|
            activity.lottery_product.description
          end

          expose :pictures do |activity|
            activity.lottery_product.posters.map(&:url)
          end

          expose :winner_self, if: lambda { |activity, opts| opts[:kol] } do |activity, opts|
            activity.lucky_kol === options[:kol]
          end

          expose :winner_name do |activity|
            activity.lucky_kol.safe_name rescue nil
          end

          expose :winner_avatar_url do |activity|
            activity.lucky_kol.avatar.url rescue nil
          end

          expose :winner_token_number do |activity|
            activity.token_number(activity.lucky_kol) rescue nil
          end
        end

        class KolingOrder < Order
          expose :kol, using: Kol, as: :kol
        end

        class ShowOrder < Order
          expose :tickets, if: lambda { |order, opts| opts[:kol] } do |order, opts|
            order.lottery_activity.token_ticket_codes(opts[:kol])
          end
        end

        class CheckingOrder < Order
          expose :lottery_activity, using: Basic, as: :activity
        end
      end
    end
  end
end

