class AddStripePaymentIntentFieldsToSpreePayments < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_payments, :stripe_payment_intent_id, :string
    add_column :spree_payments, :stripe_payment_intent_client_secret, :string

    add_index :spree_payments, :stripe_payment_intent_id
  end
end
