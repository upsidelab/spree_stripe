module SpreeStripe
  module PaymentDecorator
    def self.prepended(base)
      base.state_machine.after_transition to: :invalid, do: :stripe_after_invalidate
    end

    def stripe_after_invalidate
      return unless payment_method.class == ::SpreeStripe::PaymentElementGateway

      payment_method.cancel(nil, self)
    end
  end
end

::Spree::Payment.prepend(::SpreeStripe::PaymentDecorator)
