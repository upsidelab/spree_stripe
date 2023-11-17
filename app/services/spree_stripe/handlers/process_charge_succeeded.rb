module SpreeStripe
  module Handlers
    class ProcessChargeSucceeded
      def call(object:)
        payment = ::Spree::Payment.find_by(stripe_payment_intent_id: object.payment_intent)
        order = payment.order

        order.next!

        # Note: we need to first call order.next!, otherwise it will fail for non-captured payment
        if object.captured?
          payment.complete!
        else
          payment.pend!
        end

        payment.update!(response_code: object.balance_transaction)
      end
    end
  end
end
