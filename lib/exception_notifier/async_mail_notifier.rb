module ExceptionNotifier
  class AsyncMailNotifier
    def initialize(options)
      @options = options.reverse_merge(AsyncMailNotifier.default_options)
    end

    def call(exception, options = {})
      return
      title = "#{@options[:email_prefix]} #{exception.message}"
      messages = []
      messages << exception.inspect
      unless exception.backtrace.blank?
        messages << "\n"
        messages << exception.backtrace
      end

      ExceptionMailWorker.perform_async({
        title: title,
        message: messages,
        to: @options[:recipients],
        from: @options[:sender]
      })
    end

    def self.default_options
      {
        :sender => %("Exception Notifier" <exception.notifier@example.com>),
        :recipients => [],
        :email_prefix => "[ERROR] "
      }
    end
  end
end
