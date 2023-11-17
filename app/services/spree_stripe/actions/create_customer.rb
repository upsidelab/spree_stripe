module SpreeStripe
  module Actions
    class CreateCustomer
      def initialize(build_customer_params: ::SpreeStripe::Actions::BuildCustomerParams.new)
        @build_customer_params = build_customer_params
      end

      def call(user:, api_key:)
        ::Stripe::Customer.create(@build_customer_params.call(user: user), { api_key: api_key })
      rescue ::Stripe::InvalidRequestError => e
        raise StandardError, e.error.message
      end
    end
  end
end
