module SpreeStripe
  module Handlers
    class ProcessPaymentFailed
      CARD_DECLINED_CODE = 'card_declined'

      def call(object:)
        payment = ::Spree::Payment.find_by(stripe_payment_intent_id: object.payment_intent)
        order = payment.order

        last_payment_error = object.last_payment_error
        error_code = last_payment_error.code == CARD_DECLINED_CODE ? last_payment_error.decline_code : last_payment_error.code
        order.update!(payment_error: error_code)
      end
    end
  end
end
