module Twilio
  module REST
    class Client < BaseClient

      def initialize(*args)
        $account_sid = args[0]
        $access_token = args[1]
        # super(*args)
      end

      def method_missing(method_name, *args, &block)
        if account.respond_to?(method_name)
          account.send(method_name, *args, &block)
        elsif real_account.respond_to?(method_name)
          real_account.send(method_name, *args, &block)
        else
          super
        end
      end

      def respond_to?(method_name, include_private=false)
        if account.respond_to?(method_name, include_private)
          true
        elsif real_account.respond_to?(method_name, include_private)
          true
        else
          super
        end
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

      def real_account
        Twilio::REST::Account.new $account_sid, $access_token
      end

    end
  end
end
