module API
  module V1_3
    module Entities
      module LotteryActivityEntities
        class Kol < Grape::Entity
          expose :id, :name
          expose :avatar_url do |kol|
            kol.avatar.url rescue nil
          end
        end

        class Order < Grape::Entity
          expose :id, :code, :created_at, :number, :credits
        end

        class Basic < Grape::Entity
          expose :id, :name, :code, :published_at, :total_number, :actual_number, :status
          expose :poster_url do |activity|
            activity.poster.url rescue nil
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

          expose :winner_name do |activity|
            activity.lucky_kol.name rescue nil
          end

          expose :winner_token_number do |activity|
            activity.token_number(activity.lucky_kol) rescue nil
          end
        end

        class Show < Basic
          expose :description, :lucky_number, :draw_at
          expose :pictures do |activity|
            activity.posters.map(&:url)
          end

          expose :winner_name do |activity|
            activity.lucky_kol.name rescue nil
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

