module SpreeStripe
  module Actions
    class CreatePaymentIntent
      def initialize(build_intent_params: ::SpreeStripe::Actions::BuildPaymentIntentParams.new)
        @build_intent_params = build_intent_params
      end

      def call(payment:, api_key:)
        params = @build_intent_params.call(payment: payment)
        ::Stripe::PaymentIntent.create(params, { api_key: api_key })
      rescue ::Stripe::InvalidRequestError => e
        raise StandardError, e.error.message
      end
    end
  end
end
