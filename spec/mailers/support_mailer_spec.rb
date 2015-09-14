require "rails_helper"

RSpec.describe SupportMailer, type: :mailer do
  describe "payment_failure" do
    let(:mail) { SupportMailer.payment_failure }

    it "renders the headers" do
      expect(mail.subject).to eq("Payment failure")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

end
