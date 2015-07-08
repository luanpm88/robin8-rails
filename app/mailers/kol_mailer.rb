class KolMailer < ApplicationMailer
  def campaign_invite(kol, user, campaign)
    @user = user
    @kol = kol
    @campaign = campaign
    mail(:to => @kol.email, :subject => "You were invited to new campaign!",:from => "Robin8 <no-reply@robin8.com>")
  end
end
