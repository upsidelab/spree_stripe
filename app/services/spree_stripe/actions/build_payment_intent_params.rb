module SpreeStripe
  module Actions
    class BuildPaymentIntentParams
      def call(payment:)
        order = payment.order
        shipping_address = order.shipping_address
        payment_method = payment.payment_method

        {
          automatic_payment_methods: { enabled: true },
          amount: (order.total * 100).to_i,
          capture_method: payment_method.auto_capture? ? 'automatic' : 'manual',
          currency: order.currency,
          customer: stripe_customer_id(order, payment_method),
          shipping: {
            address: {
              line1: shipping_address.address1,
              line2: shipping_address.address2,
              city: shipping_address.city,
              postal_code: shipping_address.zipcode,
              country: shipping_address.country&.iso,
              state: shipping_address.state&.name
            },
            name: "#{shipping_address.firstname} #{shipping_address.lastname}",
            phone: shipping_address.phone
          },
          metadata: {
            spree_order: order.number
          }
        }
      end

      private

      def stripe_customer_id(order, payment_method)
        return nil if order.user.nil?

        order.user.stripe_customer_id[payment_method.id]
      end
    end
  end
end
