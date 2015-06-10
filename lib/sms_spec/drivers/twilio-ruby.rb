module Twilio
  module REST
    class Client < BaseClient

      def initialize(*args)
        options = args.last.is_a?(Hash) ? args.pop : {}
        options[:host] ||= self.class.host
        @config = Twilio::Util::ClientConfig.new options

        @account_sid = args[0] || Twilio.account_sid
        @auth_token = args[1] || Twilio.auth_token
        if @account_sid.nil? || @auth_token.nil?
          raise ArgumentError, 'Account SID and auth token are required'
        end
        $account_sid = @account_sid
        $access_token = @auth_token

        set_up_connection
        set_up_subresources
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
        @real_accounts = Twilio::REST::Accounts.new "/#{API_VERSION}/Accounts", self
        @real_account = @real_accounts.get($account_sid)
      end

    end
  end
end
