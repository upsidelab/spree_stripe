::Spree::Core::Engine.add_routes do
  if ::Spree::Core::Engine.api_available?
    get 'api/stripe/payment_intents', to: 'spree_stripe/api/payment_intents#index'
    post 'api/stripe/payment_intents', to: 'spree_stripe/api/payment_intents#create'
    post 'api/stripe/webhook', to: 'spree_stripe/api/webhooks#create'
  end

  if ::Spree::Core::Engine.frontend_available?
    scope '(:locale)', locale: /#{Spree.available_locales.join('|')}/, defaults: { locale: nil } do
      get 'stripe/payments/waiting', to: 'spree_stripe/payments#waiting'
    end
  end
end
