module Brand
  module V2
    class OnepayApi
      def self.get_direct_pay_url(config, options)
        # Get OnePay direct pay url
        data = []
        data << "vpc_AccessCode=" + config[:vpc_AccessCode]
        data << "vpc_Amount=" + options[:amount]
        data << "vpc_Command=pay"
        data << "vpc_Currency=VND" if options[:type] == 'local'
        data << "vpc_Locale=vn"
        data << "vpc_MerchTxnRef=" + options[:ref]
        data << "vpc_Merchant=" + config[:vpc_Merchant]
        data << "vpc_OrderInfo=" + options[:info]
        data << "vpc_ReturnURL=" + options[:return_url]
        data << "vpc_TicketNo=" + options[:ip]
        data << "vpc_Version=2"

        # OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), key, data)
        secureHash = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), [config[:hash_key]].pack('H*'), data.join('&')).upcase

        dataUrl = data
        dataUrl << "AgainLink=" + config[:vpc_Merchant]
        dataUrl << "Title=" + config[:vpc_Merchant]
        dataUrl << "vpc_SecureHash=" + secureHash

        onepay_recharge_url = config[:endpoint] + '?' + dataUrl.join('&')
      end

      def self.check_valid_request(secret, params)
        secure_hash = params[:vpc_SecureHash]

        data = []
        allParams = params.to_h.sort
        allParams.each do |item|
          key = item[0]
          value = item[1]
          if key != "vpc_SecureHash" && value.to_s.length > 0 && ((key[0,4] == "vpc_") || (key[0,4] =="user_"))
            data << "#{key}=#{value}"
          end
        end

        hash = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), [secret[:hash_key]].pack('H*'), data.join('&')).upcase

        return secure_hash == hash
      end
    end
  end
end
