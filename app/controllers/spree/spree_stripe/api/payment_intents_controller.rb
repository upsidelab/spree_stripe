if ::Spree::Core::Engine.api_available?
  module Spree
    module SpreeStripe
      module Api
        class PaymentIntentsController < ::Spree::Api::V2::BaseController
          include ::Spree::Api::V2::Storefront::OrderConcern

          def create
            spree_authorize! :update, spree_current_order, order_token

            payment_method = ::Spree::PaymentMethod.find(params[:payment_method_id])
            payment = ::SpreeStripe::CreatePaymentWithIntent.new.call(order: spree_current_order, payment_method: payment_method)

            render json: { stripe_payment_intent_client_secret: payment.stripe_payment_intent_client_secret }
          end

          def index
            order = ::Spree::Order.find_by!(
              store: current_store,
              token: order_token,
              currency: current_currency
            )

            spree_authorize! :show, order, order_token
            payment = order.payments.last

            render json: { state: payment.state, order_number: order.number }
          end
        end
      end
    end
  end
end
