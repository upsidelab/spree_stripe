if ::Spree::Core::Engine.api_available?
  module Spree
    module SpreeStripe
      module Api
        class WebhooksController < ActionController::API
          EVENTS = ['charge.succeeded'].freeze

          def create
            body = request.body.read
            signature = request.env['HTTP_STRIPE_SIGNATURE']

            begin
              event = ::Stripe::Webhook.construct_event(body, signature, webhook_signing_secret)
            rescue JSON::ParserError, ::Stripe::SignatureVerificationError => e
              render status: 400, json: { error_message: e }
              return
            end
            ::SpreeStripe::Handlers::ProcessWebhook.new.call(event: event) if EVENTS.include?(event.type)

            render status: 200, json: {}
          end

          private

          def webhook_signing_secret
            payment_method = Spree::PaymentMethod.find(params[:payment_method_id])
            payment_method.preferences[:webhook_signing_secret]
          end
        end
      end
    end
  end
end
