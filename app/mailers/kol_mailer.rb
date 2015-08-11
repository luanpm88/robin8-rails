class KolMailer < ApplicationMailer
  def campaign_invite(kol, user, campaign)
    @user = user
    @kol = kol
    @campaign = campaign
    mail(:to => @kol.email, :subject => "You were invited to new campaign!",:from => "Robin8 <no-reply@robin8.com>")
  end

  def send_invite(sender, mail, subject, text)
    mail(:to => mail, :from => sender, :subject => subject) do |format|
      format.html { render html: text.html_safe }
    end
  end
end
