class Subdomain
  def self.matches?(request)
    case request.subdomain
    when 'www', 'api', '', nil
      false
    else
      true
    end
  end
end