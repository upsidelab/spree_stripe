if ::Spree::Core::Engine.frontend_available?
  module Spree
    module SpreeStripe
      class PaymentsController < ::Spree::StoreController
        def waiting
          @order = ::Spree::Order.find_by(current_order_params)
          redirect_to(spree.cart_path) && return unless @order
        end
      end
    end
  end
end
