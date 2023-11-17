module SpreeStripe
  class CreatePaymentWithIntent
    def call(order:, payment_method:)
      payment = ::Spree::Payment.new(order: order, payment_method: payment_method)
      payment.amount = order.outstanding_balance

      user = order.user
      if user.present? && user.stripe_customer_id[payment_method.id].nil?
        user.stripe_customer_id[payment_method.id] = payment_method.create_customer(user).id
        user.save!
      end

      payment_intent = payment_method.create_payment_intent(payment)
      payment.stripe_payment_intent_id = payment_intent.id
      payment.stripe_payment_intent_client_secret = payment_intent.client_secret
      payment.save!

      payment
    end
  end
end
