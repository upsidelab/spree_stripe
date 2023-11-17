module SpreeStripe
  module Actions
    class CapturePaymentIntent
      def call(payment_intent_id:, amount:, api_key:)
        ::Stripe::PaymentIntent.capture(payment_intent_id, { amount_to_capture: amount }, { api_key: api_key })
        ActiveMerchant::Billing::Response.new(true, 'Payment captured successfully')
      rescue ::Stripe::InvalidRequestError => e
        ActiveMerchant::Billing::Response.new(false, e.error&.message)
      end
    end
  end
end
