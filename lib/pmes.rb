require 'rest-client'

class PMES

	Host      	= 'http://pmesmw.robin8.net:2046'
	NewMember 	= Host + '/account/new'
	BasicInfo 	= Host + '/account'
	EWalletInfo = Host + '/wallets'

	# RestClient.post(NewMember, {password: "1111111"}.to_json, {content_type: :json, accept: :json})
	def self.gen_e_wallet(password)
		RestClient.post(NewMember, {password: password}.to_json, {content_type: :json, accept: :json})
	end


	def self.get_basic(token)
		RestClient.get(BasicInfo, params: {token: token})
	end

	def self.get_e_wallet(token)
		RestClient.get(EWalletInfo, params: {token: token})
	end

	def self.transfer
		
	end

end