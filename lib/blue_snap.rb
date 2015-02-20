module BlueSnap

  class Shopper
    # URL = "https://sandbox.bluesnap.com/services/2/shoppers"
    URL = "https://sandbox.bluesnap.com/services/2/batch/order-placement"

    def self.new request,user_profile,params

      shopper =  {"shopper"=> {"web-info" => BlueSnap::Shopper.web_info(request),
                               "shopper-info" => BlueSnap::Shopper.shopper_info(params,user_profile)}, "order" => BlueSnap::Shopper.order_info()
      }

      xml_data =  shopper.to_xml(root: "batch-order")
      Request.post(URL,xml_data)
    end

    def self.order_info()
      {"cart" => cart_items(),"expected-total-price"=>{"amount"=>"199.00","currency"=>"USD"}}
    end

    def self.cart_items()
      {"cart-item" => {"sku"=>{"sku_id"=> "300406"},"quantity"=>"1"},"expected-total-price"=> {"amount"=> "199.00","currency"=> "USD"}}
      # {"sku"=> {"sku_id"=> 847283,"quantity"=>1 ,"sku-charge-price"=> {"charge-type"=>"recurring","amount"=> 199.9,"currency"=> "USD"}}}
    end

    def self.web_info(request)
      {"ip" => "117.102.37.217"}
    end

    def self.shopper_info(params,user_profile)
      {"seller-shopper-id" => "#{user_profile.id}",
       "store-id" => "14253",
       "shopper-currency"=>"USD",
       "locale"=>'en',
       "payment-info" => credit_cards(params)
      }
    end

    def self.credit_cards(params)
      {"credit_cards-info"=>
           {"credit_card-info" =>
                {"credit-card"=>
                     credit_card(params)
                }
           }
      }
    end

    def self.credit_card params
      {"encrypted-card-number" => params[:encryptedCreditCard],
       "encrypted-security-code" => params[:encryptedCvv],
       "card-type"=>params[:card][:credit_card_type],
       "expiration-month" => params[:card][:"expiration_date(2i)"],
       "expiration-year" => params[:card][:"expiration_date(1i)"]
      }
    end
  end

  class Request
    require 'net/http'
    def self.post(url,data)

      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Post.new(uri.request_uri)
      request.basic_auth(Rails.application.secrets[:bluesnap_user], Rails.application.secrets[:bluesnap_pass])
      request.body = data
      request["Content-Type"] ='application/xml'
      response = http.request(request)


      puts"Response is #{response.body}"

    end
  end

end