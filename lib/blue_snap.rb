module BlueSnap
  class Product
    def self.find(sku_id = 300406)
      url = "#{Rails.application.secrets[:bluesnap][:base_url]}/catalog/products/#{sku_id}"
      Request.get(url)
    end
  end

  class Shopper

    def self.get_subscription_id(shopper_id)
      url = "#{Rails.application.secrets[:bluesnap][:base_url]}/tools/shopper-subscriptions-retriever?shopperid=#{shopper_id}&fulldescription=true"
      begin
        error, hash = Request.get(url)
        hash[:shopper_subscriptions][:ordering_shopper][:shopper_id] if error.blank?
        resuce Exception => ex
        return nil
      end
    end


    URL = "#{Rails.application.secrets[:bluesnap][:base_url]}/batch/order-placement"

    def self.new(request, user, params, package, add_ons=nil,add_ons_hash=nil)
      begin
        errors = BlueSnap::Shopper.validate_params(params, user)
        if errors.blank?
          shopper = {
              "shopper" => {"web-info" => BlueSnap::Shopper.web_info(request),
                            "shopper-info" => BlueSnap::Shopper.shopper_info(params, user)},
              "order" => BlueSnap::Shopper.order_info(request, package, add_ons,add_ons_hash)
          }
          placeholder = cart_items(package, add_ons,add_ons_hash)
          Request.post(URL, shopper.to_xml(root: "batch-order", builder: BlueSnapXmlMarkup.new,:skip_types => true, :skip_instruct => true),placeholder)
        else
          return errors, nil
        end
      rescue Exception => ex
        Rails.logger.error ex
        return ["Something is not right with your payment. Please try again"], nil
      end
    end

    def self.validate_params(params, user)
      errors = []
      errors << "Title Name cannot be blank." if !params[:contact][:title].present?
      errors << "First name cannot be blank." if !params[:contact][:first_name].present?
      errors << "Last name cannot be blank." if !params[:contact][:last_name].present?
      errors << "Address1 cannot be blank." if !params[:contact][:address1].present?
      errors << "City cannot be blank." if !params[:contact][:city].present?
      errors << "Zip cannot be blank." if !params[:contact][:zip].present?
      errors << "Country cannot be blank." if !params[:contact][:country].present?
      errors << "Phone cannot be blank." if !params[:contact][:phone].present?
      errors << "Credit Card cannot be blank." if !params[:encryptedCreditCard].present?
      # errors << "Credit Card is not valid" if params[:encryptedCreditCard].length != 16
      errors << "CVC cannot be blank." if !params[:encryptedCvv].present?
      errors << "Credit Card Type cannot be blank." if !params[:card][:credit_card_type].present?
      errors << "Expiration Month cannot be blank." if params[:card][:expiration_month].blank? #!params[:card][:"expiration_date(2i)"].present?
      errors << "Expiration Year cannot be blank." if params[:card][:expiration_year].blank? # !params[:card][:"expiration_date(1i)"].present?
      return errors
    end


    def self.ordering_shopper request
      {"web-info" => {"ip" => "127.0.0.1", "remote-host" => "www.robin8.com", "user-agent" => request.user_agent}} #change to 127.0.0.1 to local
    end

    def self.order_info(request, package, add_ons,add_ons_hash)
      {"ordering-shopper" => ordering_shopper(request),
       "cart" => "PLACEHOLDER",
       "expected-total-price" =>
           {"amount" => get_expected_total(package,add_ons,add_ons_hash),
            "currency" => "USD"}}
    end

    def self.get_expected_total(package,add_ons,add_ons_hash)
      return package.price + (add_ons || []).collect{|a| (a.price*(add_ons_hash["#{a.id}"].to_i))}.sum
      #use discount here when required
    end

    def self.cart_items(package, add_ons,add_ons_hash)
      items = []
      items <<  {"sku" => {
          "sku_id" => package.sku_id,
          "amount" => package.price},
                 "quantity" => "1"}

      (add_ons||[]).each do |a|
        items << {
            "sku" => {
                "sku_id" => a.sku_id,
                "amount" => a.price
            },
            "quantity" => add_ons_hash["#{a.id}"] || 1
        }
      end
      items.to_xml(root: false,:children=> "cart-item",:skip_types => true, :skip_instruct => true).gsub("<objects>\n","").gsub("\n</objects>\n","") #force remove root node as per Bluesnap API ## Use builder to build each node as xml rather then using hash and building xml at end
      # items.to_xml(root: "cart",:children=> "cart-item",:skip_types => true, :skip_instruct => true)
      # {"cart-item" => items.map(&:values).flatten}
    end

    def self.web_info(request)
      {"ip" => request.ip} #"use 127.0.0.1 for local testing"
    end

    def self.shopper_info(params, user)
      {
          "shopper-contact-info" => shopper_contact_info(user, params),
          "store-id" => Rails.application.secrets[:bluesnap][:store_id],
          "shopper-currency" => "USD",
          "locale" => 'en',
          "payment-info" => credit_cards(user, params)
      }
    end

    def self.credit_cards(user, params)
      {"credit-cards-info" =>
           {"credit-card-info" =>
                {"credit-card" => credit_card(params),
                 "billing-contact-info" => billing_info(params)
                }
           }
      }
    end

    def self.credit_card params
      {
          "encrypted-card-number" => params[:encryptedCreditCard],
          "encrypted-security-code" => params[:encryptedCvv],
          "card-type" => params[:card][:credit_card_type].upcase,
          "expiration-month" => params[:card][:expiration_month], #params[:card][:"expiration_date(2i)"],
          "expiration-year" => params[:card][:expiration_year] #params[:card][:"expiration_date(1i)"]
      }
    end

    def self.billing_info(params)
      {
          "first-name" => params[:contact][:first_name],
          "last-name" => params[:contact][:last_name],
          "address1" => params[:contact][:address1],
          # "address2" => "abc",
          "city" => params[:contact][:city],
          # "state" => "pu",
          "zip" => params[:contact][:zip],
          "country" => params[:contact][:country]
      }
    end

    def self.shopper_contact_info(user, params)
      {
          "title" => params[:contact][:title],
          "first-name" => params[:contact][:first_name],
          "last-name" => params[:contact][:last_name],
          "email" => user.email,
          "address1" => params[:contact][:address1],
          "city" => params[:contact][:city],
          # "state" => "pu",
          "zip" => params[:contact][:zip],
          "country" => params[:contact][:country],
          "phone" => params[:contact][:phone]

      }
    end
  end

  class Subscription
    def self.destroy(subscription_id, shopper_id, sku_id)
      begin
        url = "#{Rails.application.secrets[:bluesnap][:base_url]}/subscriptions/#{subscription_id}"
        shopper = {"subscription-id" => subscription_id, "underlying-sku-id" => sku_id, "status" => "C", "shopper-id" => shopper_id.to_s} # status C is for cancel :s
        Request.put(url, shopper.to_xml(root: "subscription", builder: BlueSnapXmlMarkup.new))
      rescue Exception => ex
        Rails.logger.error ex
        return "Sorry we could not cancel your subscription at this time."
      end

    end

    def self.update(subscription_id, shopper_id, new_sku_id)
      begin
        url = "#{Rails.application.secrets[:bluesnap][:base_url]}/subscriptions/#{subscription_id}"
        shopper = {"subscription-id" => subscription_id.to_s, "underlying-sku-id" => new_sku_id.to_s, "status" => "A", "shopper-id" => shopper_id.to_s}
        Request.put(url, shopper.to_xml(root: "subscription", builder: BlueSnapXmlMarkup.new))
      rescue Exception => ex
        Rails.logger.error ex
        return "Sorry we could not update your subscription at this time."
      end
    end

    def self.find_all_by_shopper_id(shopper_id)
      url = "#{Rails.application.secrets[:bluesnap][:base_url]}/tools/shopper-subscriptions-retriever?shopperid=#{shopper_id}&fulldescription=true"
      errors, resp = Request.get(url)
      resp[:shopper_subscriptions][:subscriptions] if errors.blank?
    end

    def self.find_last_by_shopper_id(shopper_id)
      url = "#{Rails.application.secrets[:bluesnap][:base_url]}/tools/shopper-subscriptions-retriever?shopperid=#{shopper_id}&fulldescription=true"
      errors, resp = Request.get(url)
      resp[:shopper_subscriptions][:subscriptions][:subscription].class == Array ? resp[:shopper_subscriptions][:subscriptions][:subscription].last : resp[:shopper_subscriptions][:subscriptions][:subscription] if errors.blank?
    end

  end

  class Request
    require 'net/http'

    def self.post(url, data,placeholder)
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Post.new(uri.request_uri)
      request.basic_auth(Rails.application.secrets[:bluesnap][:user_name], Rails.application.secrets[:bluesnap][:password])
      request.body = data.gsub("PLACEHOLDER",placeholder)
      puts"data is #{data.gsub("PLACEHOLDER",placeholder).inspect} ***********"
      request["Content-Type"] ='application/xml'
      response = http.request(request)
      Rails.logger.info "************************************************************************"
      Rails.logger.info "response is #{response} AND #{response.body}***************************"
      Response.parse(response)
    end

    def self.put(url, data)
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Put.new(uri.request_uri)
      request.basic_auth(Rails.application.secrets[:bluesnap][:user_name], Rails.application.secrets[:bluesnap][:password])
      request.body = data
      request["Content-Type"] ='application/xml'
      response = http.request(request)
      Rails.logger.info "response is #{response} AND #{response.body}***************************"
      response.body
    end

    def self.get(url)
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Get.new(uri.request_uri)
      request.basic_auth(Rails.application.secrets[:bluesnap][:user_name], Rails.application.secrets[:bluesnap][:password])
      response = http.request(request)
      Response.parse(response)
    end
  end

  class Response
    def self.parse(response)
      resp = Hash.from_xml(response.body).deep_symbolize_keys
      return get_errors(resp), nil if response.code.to_i == 400 || response.code.to_i == 401
      return nil, resp
    end

    def self.get_errors(resp)
      # resps = errs = []
      # resp[:messages][:message].collect{|x|  resps << x.values if x.class == Hash}
      # resps.collect{|i| errs << i[1] if i.class == Array }
      # errs
      ["Your card was declined. Please confirm your card details below and try again."]
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


# class BlueSnap
#   include HTTParty
#   Rails.application.secrets[:bluesnap_base_url] 'https://sandbox.bluesnap.com'
#   def initialize(u, p)
#     @auth = {username: u, password: p}
#   end
#
#   def product(id,options= {})
#     options.merge!({basic_auth: @auth})
#     self.class.get("/services/2/catalog/products/#{id}", options)
#   end
#
#   def shopper(id,options= {})
#     options.merge!({basic_auth: @auth})
#     self.class.get("/services/2/catalog/shoppers/#{id}", options)
#   end
#
# end
# snap = BlueSnap.new(Rails.application.secrets[:bluesnap_user], Rails.application.secrets[:bluesnap_pass])

