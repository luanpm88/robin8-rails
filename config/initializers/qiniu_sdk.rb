require 'qiniu'

Qiniu.establish_connection! :access_key => Rails.application.secrets.qiniu[:access_key],
                            :secret_key => Rails.application.secrets.qiniu[:secret_key]
