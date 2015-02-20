module BlueSnap

  class Product
    def self.find(sku_id = 300406)
      url = "https://sandbox.bluesnap.com/services/2/catalog/products/#{sku_id}"
      Request.get(url)
    end
  end

  class Shopper
    URL = "https://sandbox.bluesnap.com/services/2/batch/order-placement"

    def self.new request,user_profile,params
      shopper ={
          "shopper"=> {"web-info" => BlueSnap::Shopper.web_info(request),
                       "shopper-info" => BlueSnap::Shopper.shopper_info(params,user_profile)},
          "order" => BlueSnap::Shopper.order_info(request)
      }

      Request.post(URL,shopper.to_xml(root: "batch-order"))
    end

    def self.ordering_shopper request
      {"web-info" =>{"ip" =>request.ip,"remote-host"=> "www.razeekhan.com","user-agent" => request.user_agent} }
    end

    def self.order_info(request)
      {"ordering-shopper" =>ordering_shopper(request) ,
       "cart" => cart_items(),
       "expected-total-price"=>
           {"amount"=>"199.00",
            "currency"=>"USD"}}
    end

    def self.cart_items()
      {"cart-item" => {"sku"=>{
          "sku_id"=> "2153556",
          "amount"=> "199.00"},
                       "quantity"=>"1"}}
    end

    def self.web_info(request)
      {"ip" => request.ip} #, "remote-host" => "", "user-agent" =>""}
    end

    def self.shopper_info(params,user_profile)
      {
          "shopper-contact-info" => shopper_contact_info(),
          "store-id" => "14253",
          "shopper-currency"=>"USD",
          "locale"=>'en',
          "payment-info" => credit_cards(params)
      }
    end

    def self.credit_cards(params)
      {"credit-cards-info"=>
           {"credit-card-info" =>
                {"credit-card"=> credit_card(params),
                 "billing-contact-info" => billing_info()
                }
           }
      }
    end

    def self.credit_card params
      {
          "encrypted-card-number" => params[:encryptedCreditCard],
          "encrypted-security-code" => params[:encryptedCvv],
          "card-type"=>params[:card][:credit_card_type].upcase,
          "expiration-month" => params[:card][:"expiration_date(2i)"],
          "expiration-year" => params[:card][:"expiration_date(1i)"]
      }
    end

    def self.billing_info
      {
          "first-name" => "Razee",
          "last-name" => "Khan",
          "address1" => "abc",
          "address2" => "abc",
          "city"=> "Lhahore",
          "state" => "pu",
          "zip" => "5400",
          "country"=> "Pakistan"
      }
    end

    def self.shopper_contact_info
      {
          "title" => "Mr",
          "first-name" => "Razee",
          "last-name" => "khan",
          "email" => "rehan.munir@engintechnologies.com",
          "company-name" => "abc",
          "address1" => "138 abc",
          "city"=> "Lahore",
          "zip" => "54000",
          "state" => "pu",
          "country"=> "Pakistan",
          "phone" => "03317970187",
          "fax" => "540008171771"

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

    end

    def self.get(url)
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Get.new(uri.request_uri)
      request.basic_auth(Rails.application.secrets[:bluesnap_user], Rails.application.secrets[:bluesnap_pass])
      response = http.request(request)
    end

  end

end