# frozen_string_literal: true

module SpreeStripe
  class PaymentElementGateway < ::Spree::Gateway
    preference :secret_key, :password
    preference :publishable_key, :password
    preference :webhook_signing_secret, :password

    def source_required?
      false
    end

    def provider
      self
    end

    def provider_class
      ::SpreeStripe::PaymentElementGateway
    end

    def method_type
      'stripe_payment_element'
    end

    def actions
      %w[capture void credit]
    end

    def capture(amount, _authorization, gateway_options)
      payment_number = gateway_options[:order_id].split('-')[1] # TODO maybe there's a better way to get payment here
      payment = ::Spree::Payment.find_by!(number: payment_number)
      ::SpreeStripe::Actions::CapturePaymentIntent.new.call(
        payment_intent_id: payment.stripe_payment_intent_id,
        amount: amount,
        api_key: api_key
      )
    end

    def can_credit?(payment)
      payment.state == 'completed'
    end

    def credit(amount, _credit_card, gateway_options, _options = {})
      payment = gateway_options[:originator].payment

      ::SpreeStripe::Actions::RefundPaymentIntent.new.call(
        payment_intent_id: payment.stripe_payment_intent_id,
        amount: amount,
        api_key: api_key
      )
    end

    def cancel(_response_code, payment)
      ::SpreeStripe::Actions::CancelPaymentIntent.new.call(
        payment_intent_id: payment.stripe_payment_intent_id,
        api_key: api_key
      )
    end

    def can_void?(payment)
      %w[checkout processing].include?(payment.state)
    end

    def void(_response_code, _credit_card, payment)
      ::SpreeStripe::Actions::CancelPaymentIntent.new.call(
        payment_intent_id: payment.stripe_payment_intent_id,
        api_key: api_key
      )
    end

    def create_customer(user)
      ::SpreeStripe::Actions::CreateCustomer.new.call(
        user: user,
        api_key: api_key
      )
    end

    def create_payment_intent(payment)
      ::SpreeStripe::Actions::CreatePaymentIntent.new.call(
        payment: payment,
        api_key: api_key
      )
    end

    private

    def secret_key_valid?(secret_key)
      ::SpreeStripe::Actions::ValidateSecretKey.new.call(
        api_key: api_key
      )
    end

    def api_key
      preferences[:secret_key]
    end

    def public_preference_keys
      %w[publishable_key]
    end
  end
end
