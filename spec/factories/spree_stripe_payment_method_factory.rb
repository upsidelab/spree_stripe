FactoryBot.define do
  factory :spree_stripe_payment_method, parent: :payment_method, class: SpreeStripe::PaymentElementGateway do
    type          { 'SpreeStripe::PaymentElementGateway' }
    name          { 'Stripe Payment Element' }
    description   { 'Stripe Payment Element' }
    active        { true }
    auto_capture  { true }
  end
end
