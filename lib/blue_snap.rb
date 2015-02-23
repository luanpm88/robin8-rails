module BlueSnap
  base_uri = "https://sandbox.bluesnap.com"
  #user httparty as listed below for complete API integration
  class Product
    def self.find(sku_id = 300406)
      url = "https://sandbox.bluesnap.com/services/2/catalog/products/#{sku_id}"
      Request.get(url)
    end
  end

  class Shopper
    URL = "https://sandbox.bluesnap.com/services/2/batch/order-placement"

    def self.new request,user_profile,params,package
      shopper ={
          "shopper"=> {"web-info" => BlueSnap::Shopper.web_info(request),
                       "shopper-info" => BlueSnap::Shopper.shopper_info(params,user_profile)},
          "order" => BlueSnap::Shopper.order_info(request,package)
      }
      Request.post(URL,shopper.to_xml(root: "batch-order", builder: BlueSnapXmlMarkup.new))
    end

    def self.ordering_shopper request
      {"web-info" =>{"ip" =>request.ip,"remote-host"=> "www.myprgenie.com","user-agent" => request.user_agent} } #change to 127.0.0.1 to local
    end

    def self.order_info(request,package)
      {"ordering-shopper" =>ordering_shopper(request) ,
       "cart" => cart_items(package),
       "expected-total-price"=>
           {"amount"=> package.price,
            "currency"=>"USD"}}
    end

    def self.cart_items(package)
      {"cart-item" => {"sku"=>{
          "sku_id"=> package.sku_id, #"2153556",
          "amount"=> package.price},
                       "quantity"=>"1"}}
    end

    def self.web_info(request)
      {"ip" => "123.00.1.1"} #requst.ip
    end

    def self.shopper_info(params,user)
      {
          "shopper-contact-info" => shopper_contact_info(user),
          "store-id" => Rails.application.secrets[:bluesnap_store_id],
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
          # "address2" => "abc",
          "city"=> "Lahore",
          # "state" => "pu",
          "zip" => "5400",
          "country"=> "pk"
      }
    end

    def self.shopper_contact_info(user)
      {
          "title" => "Mr",
          "first-name" => user.first_name,
          "last-name" => user.last_name,
          "email" => user.email,
          # "company-name" => "abc",
          "address1" => "138 abc",
          "city"=> "Lahore",
          "zip" => "54000",
          # "state" => "pu",
          "country"=> "pk",
          "phone" => "03317970187"

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
      Response.parse(response)
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

  class Response
    def self.parse(response)
      puts"orignal is :#{response.inspect}"
      resp = Hash.from_xml(response.body)
      puts resp
      return get_errors(resp.deep_symbolize_keys),nil  if response.code == 400
      return nil,resp
    end

    def self.get_errors(resp)
      resps = errs = []
      resp[:messages][:message].collect{|x|  resps << x.values if x.class == Hash}
      resps.collect{|i| errs << i[1] if i.class == Array }
      errs
    end
  end



  require 'builder/xmlmarkup'
  class BlueSnapXmlMarkup < ::Builder::XmlMarkup
    def tag!(sym, *args, &block)
      if @level == 0
        args << {"xmlns" => "http://ws.plimus.com"}
      end
      super(sym, *args, &block)
    end
  end

end
# dir = File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
# require File.join(dir, 'httparty')
#
# class BlueSnap
#   include HTTParty
#   base_uri 'sandbox.bluesnap.com'
#   def initialize(u, p)
#     @auth = {username: u, password: p}
#   end
#
#   def product(id)
#     options.merge!({basic_auth: @auth})
#     self.class.get("/services/2/catalog/products/#{id}", options)
#   end
#
#   def shopper(id)
#     options.merge!({basic_auth: @auth})
#     self.class.get("/services/2/catalog/shoppers/#{id}", options)
#   end
#
# end
# snap = BlueSnap.new(Rails.application.secrets[:bluesnap_user], Rails.application.secrets[:bluesnap_pass])

