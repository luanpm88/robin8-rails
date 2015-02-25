require 'rubygems'
require 'active_resource'
module Blue
  class Base <  ActiveResource::Base
    self.site = "https://sandbox.bluesnap.com/services/2"
    self.format = :xml
    self.include_format_in_path = false
    self.auth_type = :basic
    self.user = Rails.application.secrets[:bluesnap_user]
    self.password = Rails.application.secrets[:bluesnap_pass]
  end

  class Product < Base
    self.site = "https://sandbox.bluesnap.com/services/2/catalog"
  end

  class Shopper < Base

  end


  class Order < Base

  end


  # def OrderShopper < Base
  #   self.site = "https://sandbox.bluesnap.com/services/2/batch/order-placement"
  # end


  class Subscription < Base

  end

  ##Overide default encoding for XML of ActiveResource::Base and define your own custom encoder to BlueSnap
  # require 'builder/xmlmarkup'
  # class BlueSnapXmlMarkup < ::Builder::XmlMarkup
  #   def tag!(sym, *args, &block)
  #     if @level == 0
  #       args << {"xmlns" => "http://ws.plimus.com"}
  #     end
  #     super(sym, *args, &block)
  #   end
  # end

  # require 'active_support/core_ext/hash/conversions'
  # module ActiveResource
  #   module Formats
  #     module XmlCustomFormat
  #       extend self
  #
  #       def extension
  #         "xml"
  #       end
  #
  #       def mime_type
  #         "application/xml"
  #       end
  #
  #       def encode(hash, options={})
  #         hash.to_xml(root: "batch-order", builder: BlueSnapXmlMarkup.new))
  #       end
  #
  #       def decode(xml)
  #         Formats.remove_root(Hash.from_xml(xml))
  #       end
  #     end
  #   end
  # end
end
