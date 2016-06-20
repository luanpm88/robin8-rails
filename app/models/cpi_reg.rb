class CpiReg < ActiveRecord::Base

  def self.create_reg(params)
     cpi_reg = self.create!(appid: params[:appid], bundle_name: params[:bundle_name], app_platform: params[:app_platform],
                            app_version: params[:app_version],
                            os_version: params[:os_version], device_model:params[:device_model], reg_ip: params[:reg_ip])
     CampaignShow.update_inviter(cpi_reg)
  end

end
