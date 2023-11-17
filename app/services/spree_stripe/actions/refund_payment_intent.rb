module SpreeStripe
  module Actions
    class RefundPaymentIntent
      REFUNDED_STATUS = 'charge_already_refunded'

      def call(payment_intent_id:, amount:, api_key:)
        ::Stripe::Refund.create({ payment_intent: payment_intent_id, amount: amount }, { api_key: api_key })
        ActiveMerchant::Billing::Response.new(true, 'Payment refunded successfully')
      rescue ::Stripe::InvalidRequestError => e
        if e.error&.payment_intent&.status == REFUNDED_STATUS
          ::Stripe::PaymentIntent.retrieve(payment_intent_id, { api_key: api_key })
          return ActiveMerchant::Billing::Response.new(true, 'Payment already refunded')
        end

        ActiveMerchant::Billing::Response.new(false, e.error&.message)
      end
    end
  end
end
