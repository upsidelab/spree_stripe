module SpreeStripe
  module Actions
    class ValidateSecretKey
      def call(api_key:)
        ::Stripe::Customer.list({ limit: 1 }, { api_key: api_key })
        true
      rescue ::Stripe::AuthenticationError, ::Stripe::PermissionError
        false
      end
    end
  end
end
