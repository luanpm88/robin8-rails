class ExceptionMailWorker
  include Sidekiq::Worker
  sidekiq_options  :queue => :exception_mail

  def perform(opts={})
      ExceptionMailer.deliver_notification(opts[:title], opts[:message], to: opts[:recipients], from: opts[:from])
  end
end