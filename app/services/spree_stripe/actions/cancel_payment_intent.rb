module SpreeStripe
  module Actions
    class CancelPaymentIntent
      CANCELED_STATUS = 'canceled'

      def call(payment_intent_id:, api_key:)
        ::Stripe::PaymentIntent.cancel(payment_intent_id, {}, { api_key: api_key })
        ActiveMerchant::Billing::Response.new(true, 'Payment cancelled successfully')
      rescue ::Stripe::InvalidRequestError => e
        if e.error&.payment_intent&.status == CANCELED_STATUS
          ::Stripe::PaymentIntent.retrieve(payment_intent_id, { api_key: api_key })
          return ActiveMerchant::Billing::Response.new(true, 'Payment cancelled successfully')
        end

        ActiveMerchant::Billing::Response.new(false, e.error&.message)
      end
    end
  end
end
