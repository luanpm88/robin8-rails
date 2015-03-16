class Subdomain
  def self.matches?(request)
    case request.subdomain
    when 'www', 'api', 'staging', '', nil
      false
    else
      true
    end
  end
end
