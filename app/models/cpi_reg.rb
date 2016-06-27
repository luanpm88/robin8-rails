class CpiReg < ActiveRecord::Base

  ApiToken = "ecce21119d1931d238cebfb53107bf5e"
  def self.valid_data?(data)
    data.is_a?(Hash) &&  data['appid'].present? &&  data['device_uuid'].present?   && data['api_token'] == ApiToken
  end

  def self.had_reg?(data)
    CpiReg.where(:appid => data['appid'], :device_uuid => data['device_uuid']).where(:status => 'success').size > 0
  end

  def self.create_reg(params, decry_data)
     cpi_reg = self.create!(bundle_name: params[:bundle_name], app_platform: params[:app_platform],
                            app_version: params[:app_version], city_name: params[:city_name],
                            os_version: params[:os_version], device_model:params[:device_model], reg_ip: params[:reg_ip],
                            appid: decry_data['appid'], device_uuid: decry_data['device_uuid'])
     CampaignShow.update_inviter(cpi_reg)
  end

end
