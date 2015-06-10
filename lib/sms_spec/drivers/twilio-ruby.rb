module Twilio
  module REST
    class Client < BaseClient
      API_VERSION = '2010-04-01'
      attr_reader :account, :accounts

      host 'api.twilio.com'

      def initialize(*args)
        $account_sid = args[0]
        super(*args)
      end

      class Messages
        include SmsSpec::Helpers

        def create(opts={})
          to = opts[:to]
          body = opts[:body]
          add_message SmsSpec::Message.new(:number => to, :body => body)
        end
      end

      class Sms
        def messages
          return Messages.new
        end
      end

      class Account
        def sms
          return Sms.new
        end
      end

      def account
        account = Account.new
        account.class.send(:define_method, :sid, lambda { $account_sid })
        account
      end
    end
  end
end
