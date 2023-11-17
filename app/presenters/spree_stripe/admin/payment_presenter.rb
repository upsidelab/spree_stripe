module SpreeStripe
  module Admin
    class PaymentPresenter
      def initialize(payment)
        @payment = payment
      end

      def payment_intent_id
        @payment.stripe_payment_intent_id
      end

      def stripe_dashboard_url
        return nil unless @payment.stripe_payment_intent_id.present?

        server = @payment.payment_method.preferences[:server]

        "https://dashboard.stripe.com/#{server}/payments/#{@payment.stripe_payment_intent_id}"
      end
    end
  end
end
